import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/backend/member_controller.dart';
import 'package:nakoda_ji/apps/member/screens/auth/widgets/document_status_list.dart';
import 'package:nakoda_ji/apps/member/screens/auth/widgets/info_display_widgets.dart';
import 'package:nakoda_ji/apps/member/screens/auth/widgets/member_status_skeleton.dart';
import 'package:nakoda_ji/apps/member/screens/auth/widgets/status_action_card.dart';
import 'package:nakoda_ji/apps/member/screens/auth/widgets/status_banner_card.dart';
import 'package:nakoda_ji/backend/models/membership_model.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/components/appbar/commen_appbar.dart';
import 'package:nakoda_ji/components/appbar/custom_drawer.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nakoda_ji/apps/member/screens/auth/widgets/payment_failed_popup.dart';
import 'package:nakoda_ji/apps/member/screens/auth/widgets/payment_success_popup.dart';
import 'package:nakoda_ji/apps/member/screens/biometric/biometric_booking_page.dart';

class MemberStatusPage extends StatefulWidget {
  final String applicationId;
  final VoidCallback? onEdit;

  const MemberStatusPage({super.key, required this.applicationId, this.onEdit});

  @override
  State<MemberStatusPage> createState() => _MemberStatusPageState();
}

class _MemberStatusPageState extends State<MemberStatusPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  Map<String, dynamic>? _reviewData;
  MembershipModel? _application;

  // Razorpay
  late Razorpay _razorpay;
  String get _razorpayKey => dotenv.env['RAZORPAY_KEY_ID'] ?? '';

  @override
  void initState() {
    super.initState();
    print('🚀 [MemberStatusPage] Init. AppID: ${widget.applicationId}');
    _initializeRazorpay();
    _fetchReviewData();
  }

  void _initializeRazorpay() {
    print('🚀 [MemberStatusPage] Initializing Razorpay');
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  Future<void> _fetchReviewData({bool isRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reviewResponse = await MemberController.getMembershipReviewStatus(
        widget.applicationId,
      );
      final appResponse = await MemberController.fetchMembershipModelById(
        widget.applicationId,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (reviewResponse.isSuccess()) {
            _reviewData = reviewResponse.data;
          } else {
            print(
              "⚠️ Review Status API failed or empty: ${reviewResponse.message}",
            );
          }

          if (appResponse != null) {
            _application = appResponse;
          } else {
            print("⚠️ Application Model API returned null");
          }
        });

        print("📊 MemberStatusPage State:");
        print("- Application Loaded: ${_application != null}");
        print("- Review Data Loaded: ${_reviewData != null}");
      }
    } catch (e) {
      print("❌ Exception in _fetchReviewData: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching status: $e")));
      }
    }
  }

  Future<void> _initiatePayment() async {
    // 1. Create Order
    // Read from .env
    String envFee = dotenv.env['MEMBER_REGISTRATION_FEE'] ?? '500';
    final double amountInRupees = double.tryParse(envFee) ?? 500.0;

    // Check if backend expects Paise or Rupees
    // Since previous attempt with 500 resulted in 5 Rs (500 paise),
    // it implies backend expects PAISE.
    // So 500 Rs = 500 * 100 = 50000 Paise.
    final double amountInPaise = amountInRupees * 100;

    print("💰 Initiating Payment: ₹$amountInRupees ($amountInPaise paise)");

    try {
      final response = await MemberController.createPaymentOrder(
        widget.applicationId,
        amountInPaise, // Sending Paise to match backend expectation
      );

      if (response.isSuccess() && response.data != null) {
        // Updated to match API docs: 'orderId' instead of 'id'
        final orderId = response.data['orderId'] ?? response.data['id'];
        final apiKey = response.data['key'] ?? _razorpayKey;

        // 2. Open Razorpay Checkout
        var options = {
          'key': apiKey,
          'amount': amountInPaise, // Amount is NOW in paise
          'name': 'Nakoda Ji',
          'description': 'Membership Fee',
          'order_id': orderId,
          'prefill': {
            'contact': _application?.phone ?? '',
            'email': _application?.email ?? '',
          },
          'external': {
            'wallets': ['paytm'],
          },
        };

        _razorpay.open(options);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to create payment order: ${response.message}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error initiating payment: $e")));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('✅ [Razorpay] Payment Success Callback Triggered');
    print('   - Payment ID: ${response.paymentId}');
    print('   - Order ID: ${response.orderId}');
    print('   - Signature: ${response.signature}');

    // Verify Payment Server-Side
    try {
      final verifyResponse = await MemberController.verifyPayment(
        paymentId: response.paymentId!,
        signature: response.signature!,
        orderId: response.orderId!,
      );

      print(
        '🔄 [Razorpay] Verification API Response: ${verifyResponse.message}',
      );
      print('   - Success: ${verifyResponse.isSuccess()}');

      if (verifyResponse.isSuccess()) {
        if (mounted) {
          // Get Member Details
          final String memberName =
              "${_application?.firstName ?? ''} ${_application?.lastName ?? ''}";

          String envFee = dotenv.env['MEMBER_REGISTRATION_FEE'] ?? '500';
          final double finalAmount = double.tryParse(envFee) ?? 500.0;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => PaymentSuccessPopup(
              transactionId:
                  response.paymentId!, // Use paymentId from Razorpay callback
              memberName: memberName.trim().isEmpty ? 'Member' : memberName,
              applicationId: widget.applicationId,
              amount: finalAmount,
              date: DateTime.now(),
              onDismiss: () {
                Navigator.of(context).pop();
                // Navigate to Biometric Booking Page
                AppNavigation(context).pushReplacement(
                  BiometricBookingPage(
                    membershipApplicationId: widget.applicationId,
                  ),
                );
              },
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Payment verification failed: ${verifyResponse.message}",
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ [Razorpay] Verification Exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error verifying payment: $e")));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('❌ [Razorpay] Payment Error Callback Triggered');
    print('   - Code: ${response.code}');
    print('   - Message: ${response.message}');
    print('   - Metadata: ${response.error}');

    // Record failure as per documentation
    MemberController.recordFailedPayment(
      applicationId: widget.applicationId,
      paymentId: response.error?.toString() ?? 'unknown_error',
      signature: response.message ?? 'Payment Failed',
    ).then((res) {
      print("📝 [Razorpay] Failed payment recorded via API: ${res.message}");
    });

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PaymentFailedPopup(
          errorMessage: response.message ?? "An unknown error occurred.",
          onRetry: () {
            Navigator.of(context).pop();
            _initiatePayment();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('👛 [Razorpay] External Wallet Selected');
    print('   - Wallet Name: ${response.walletName}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet Selected: ${response.walletName}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xffF8FAFC),
        appBar: CommonAppBar(scaffoldKey: _scaffoldKey),
        endDrawer: CustomDrawer(isReviewMode: true),
        body: const MemberStatusSkeleton(),
      );
    }

    if (_application == null) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xffF8FAFC),
        appBar: CommonAppBar(scaffoldKey: _scaffoldKey),
        endDrawer: CustomDrawer(isReviewMode: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade200),
              const SizedBox(height: 16),
              const Text("Failed to load application details"),
              const SizedBox(height: 8),
              if (_reviewData != null)
                const Text(
                  "Review data loaded, but application details missing",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchReviewData,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    String status = (_application?.status ?? 'SUBMITTED').toUpperCase();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xffF8FAFC),
      appBar: CommonAppBar(scaffoldKey: _scaffoldKey),
      endDrawer: CustomDrawer(
        isReviewMode: ![
          'PAYMENT_COMPLETED',
          'PAID',
          'BIOMETRIC_PENDING',
        ].contains(status),
        isBiometricMode: [
          'PAYMENT_COMPLETED',
          'PAID',
          'BIOMETRIC_PENDING',
        ].contains(status),
        applicationId: widget.applicationId,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchReviewData(isRefresh: true);
        },
        backgroundColor: Colors.white,
        color: CustomColors.clrBtnBg,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopStatusLabel(status: status),
              const SizedBox(height: 16),
              StatusBannerCard(status: status, onEdit: widget.onEdit),
              const SizedBox(height: 32),

              const InfoSectionHeader(
                title: "Personal Information",
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              InfoCategoryCard(
                children: [
                  _infoItem("First Name", _application?.firstName, "firstName"),
                  _infoItem("Last Name", _application?.lastName, "lastName"),
                  _infoItem(
                    "Father's Name",
                    _application?.fathersName,
                    "fathersName",
                  ),
                  _infoItem("Gender", _application?.gender, "gender"),
                  _infoItem(
                    "Date of Birth",
                    _formatDate(_application?.dob),
                    "dateOfBirth",
                  ),
                  _infoItem(
                    "Aadhaar Number",
                    _formatAadhaar(_application?.aadhaarNumber),
                    "aadhaarNumber",
                  ),
                  _infoItem(
                    "Jan Aadhaar ID",
                    _application?.familyId,
                    "janAadhaarFamilyId",
                  ),
                  _infoItem(
                    "Area",
                    _application?.area?.name ??
                        _reviewData?['area']?['name'] ??
                        _reviewData?['areaName'] ??
                        _reviewData?['areaId']?.toString(),
                    "areaId",
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const InfoSectionHeader(
                title: "Contact Details",
                icon: Icons.contact_page_outlined,
              ),
              const SizedBox(height: 12),
              InfoCategoryCard(
                children: [
                  _infoItem("Email Address", _application?.email, "email"),
                  _infoItem(
                    "Phone Number",
                    "${_application?.phoneCode} ${_application?.phone}",
                    "phoneNumber",
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const InfoSectionHeader(
                title: "Permanent Address",
                icon: Icons.home_rounded,
              ),
              const SizedBox(height: 12),
              InfoCategoryCard(
                children: [
                  _infoItem(
                    "Address Line 1",
                    _application?.permanentAddressLine1,
                    "permanentAddressLine1",
                  ),
                  _infoItem(
                    "Address Line 2",
                    _application?.permanentAddressLine2,
                    "permanentAddressLine2",
                  ),
                  _infoItem(
                    "City",
                    _application?.permanentCity,
                    "permanentCity",
                  ),
                  _infoItem(
                    "State",
                    _application?.permanentState,
                    "permanentState",
                  ),
                  _infoItem(
                    "Zip Code",
                    _application?.permanentZipCode,
                    "permanentZipCode",
                  ),
                  _infoItem(
                    "Years of Stay",
                    _application?.yearsInPermanentAddress?.toString(),
                    "yearsInPermanentAddress",
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const InfoSectionHeader(
                title: "Current Address",
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              InfoCategoryCard(
                children: [
                  _infoItem(
                    "Address Line 1",
                    _application?.currentAddressLine1,
                    "currentAddressLine1",
                  ),
                  _infoItem(
                    "Address Line 2",
                    _application?.currentAddressLine2,
                    "currentAddressLine2",
                  ),
                  _infoItem("City", _application?.currentCity, "currentCity"),
                  _infoItem(
                    "State",
                    _application?.currentState,
                    "currentState",
                  ),
                  _infoItem(
                    "Zip Code",
                    _application?.currentZipCode,
                    "currentZipCode",
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const InfoSectionHeader(
                title: "Submitted Documents",
                icon: Icons.folder_open_outlined,
              ),
              const SizedBox(height: 12),
              DocumentStatusList(
                reviewData: _reviewData,
                applicationId: widget.applicationId,
                onSuccess: _fetchReviewData,
                application: _application,
              ),

              const SizedBox(height: 40),
              if (status == 'APPROVED')
                StatusActionCard(
                  title: "Finalize Membership",
                  subtitle:
                      "Verification successful! Complete your payment to activate your membership.",
                  icon: Icons.account_balance_wallet_outlined,
                  btnLabel: "Pay Now",
                  onTap: _initiatePayment,
                  gradient: [const Color(0xff0F172A), const Color(0xff334155)],
                ),

              if ([
                'PAYMENT_COMPLETED',
                'PAID',
                'BIOMETRIC_PENDING',
              ].contains(status))
                StatusActionCard(
                  title: "Biometric Verification",
                  subtitle:
                      "Payment successful! Please book your biometric slot to proceed.",
                  icon: Icons.fingerprint,
                  btnLabel: "Book Slot",
                  onTap: () {
                    AppNavigation(context).pushReplacement(
                      BiometricBookingPage(
                        membershipApplicationId: widget.applicationId,
                      ),
                    );
                  },
                  gradient: [const Color(0xff059669), const Color(0xff10B981)],
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String? value, String fieldName) {
    return InfoItemRow(
      label: label,
      value: value,
      fieldName: fieldName,
      reviewData: _reviewData,
      applicationId: widget.applicationId,
      onSuccess: _fetchReviewData,
      application: _application,
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return "N/A";
    try {
      if (date is DateTime) {
        return "${date.day}/${date.month}/${date.year}";
      }
      DateTime dt = DateTime.parse(date.toString());
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (e) {
      return date.toString();
    }
  }

  String _formatAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.isEmpty) return "N/A";
    String clean = aadhaar.replaceAll(' ', '');
    if (clean.length != 12) return aadhaar;
    return "${clean.substring(0, 4)} ${clean.substring(4, 8)} ${clean.substring(8, 12)}";
  }
}
