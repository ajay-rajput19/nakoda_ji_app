import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/backend/member_controller.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_register_page.dart';
import 'package:nakoda_ji/backend/models/membership_model.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

class MemberStatusPage extends StatefulWidget {
  final String applicationId;
  final VoidCallback? onEdit;

  const MemberStatusPage({super.key, required this.applicationId, this.onEdit});

  @override
  State<MemberStatusPage> createState() => _MemberStatusPageState();
}

class _MemberStatusPageState extends State<MemberStatusPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _reviewData;
  MembershipModel? _application;

  @override
  void initState() {
    super.initState();
    _fetchReviewData();
  }

  Future<void> _fetchReviewData() async {
    setState(() => _isLoading = true);
    final response = await MemberController.getMembershipReviewProfile(
      widget.applicationId,
    );

    if (response.isSuccess() && response.data != null) {
      setState(() {
        _reviewData = response.data;
        if (response.data['application'] != null) {
          _application = MembershipModel.fromJson(response.data['application']);
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _reviewData == null) {
      return Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        appBar: _buildAppBar(),
        body: _buildSkeleton(),
      );
    }

    if (_reviewData == null || _application == null) {
      return Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade200),
              const SizedBox(height: 16),
              const Text("Failed to load application status"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchReviewData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.clrBtnBg,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchReviewData,
        backgroundColor: Colors.white,
        color: CustomColors.clrBtnBg,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopStatusLabel(),
              const SizedBox(height: 16),
              _buildStatusBanner(),
              const SizedBox(height: 32),

              _buildSectionHeader(
                "Personal Information",
                Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              _buildInfoCategory([
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
                      _reviewData?['areaId']?.toString(), // Last resort fallback
                  "areaId",
                ),
              ]),

              const SizedBox(height: 32),
              _buildSectionHeader(
                "Contact Details",
                Icons.contact_page_outlined,
              ),
              const SizedBox(height: 12),
              _buildInfoCategory([
                _infoItem("Email Address", _application?.email, "email"),
                _infoItem(
                  "Phone Number",
                  "${_application?.phoneCode} ${_application?.phone}",
                  "phoneNumber",
                ),
              ]),

              const SizedBox(height: 32),
              _buildSectionHeader("Permanent Address", Icons.home_rounded),
              const SizedBox(height: 12),
              _buildInfoCategory([
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
                _infoItem("City", _application?.permanentCity, "permanentCity"),
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
              ]),

              const SizedBox(height: 32),
              _buildSectionHeader(
                "Current Address",
                Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              _buildInfoCategory([
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
                _infoItem("State", _application?.currentState, "currentState"),
                _infoItem(
                  "Zip Code",
                  _application?.currentZipCode,
                  "currentZipCode",
                ),
              ]),

              const SizedBox(height: 32),
              _buildSectionHeader(
                "Submitted Documents",
                Icons.folder_open_outlined,
              ),
              const SizedBox(height: 12),
              _buildDocumentReviewList(),

              const SizedBox(height: 40),
              if (_reviewData?['canPay'] == true)
                _buildActionCard(
                  "Finalize Membership",
                  "Verification successful! Complete your payment to activate your membership.",
                  Icons.account_balance_wallet_outlined,
                  "Pay Now",
                  () {},
                  [const Color(0xff0F172A), const Color(0xff334155)],
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCategory(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _infoItem(String label, String? value, String fieldName) {
    String status = _getFieldStatus(fieldName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildBadge(status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value ?? "N/A",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _getFieldStatus(String fieldName) {
    List<dynamic> fields = _reviewData?['fieldReviews'] ?? [];
    final review = fields.firstWhere(
      (f) => f['fieldName'] == fieldName,
      orElse: () => null,
    );
    return review?['status'] ?? 'PENDING';
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

  Widget _buildStatusBanner() {
    String status = (_application?.status ?? 'SUBMITTED').toUpperCase();
    bool needsChanges = status == 'REJECTED' || status == 'CHANGES_REQUESTED';

    Color baseColor;
    IconData icon;
    String title;
    List<Color> gradient;

    switch (status) {
      case 'APPROVED':
        baseColor = const Color(0xff10B981);
        icon = Icons.verified_user_rounded;
        title = "Application Approved";
        gradient = [const Color(0xff10B981), const Color(0xff059669)];
        break;
      case 'REJECTED':
      case 'CHANGES_REQUESTED':
        baseColor = const Color(0xffEF4444);
        icon = Icons.error_outline_rounded;
        title = status == 'REJECTED'
            ? "Application Rejected"
            : "Changes Required";
        gradient = [const Color(0xffEF4444), const Color(0xffDC2626)];
        break;
      default:
        baseColor = const Color(0xff3B82F6);
        icon = Icons.pending_actions_rounded;
        title = "Under Review";
        gradient = [const Color(0xff3B82F6), const Color(0xff2563EB)];
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(icon, color: Colors.white.withOpacity(0.15), size: 120),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: CustomFonts.poppins,
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getStatusMessage(status),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (needsChanges && widget.onEdit != null) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: widget.onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: baseColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      "Update Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'APPROVED':
        return "Your application has been verified. You can now proceed to final membership activation.";
      case 'REJECTED':
        return "Your application was not approved. Please review the remarks below for details.";
      case 'CHANGES_REQUESTED':
        return "Some details in your application need correction. Please update them and resubmit.";
      default:
        return "Our enrollment team is currently reviewing your profile and documents. We'll notify you soon.";
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: CustomColors.clrBtnBg,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: Colors.grey.shade400, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: CustomFonts.poppins,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentReviewList() {
    List<dynamic> docs = _reviewData?['documents'] ?? [];
    if (docs.isEmpty) return const SizedBox.shrink();

    return Column(
      children: docs.map((doc) {
        String name =
            doc['originalName'] ?? doc['documentType']?['name'] ?? 'Document';
        String status = doc['review']?['status'] ?? 'PENDING';
        String? remark = doc['review']?['remark'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.file_copy_rounded,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (remark != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          remark,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _buildBadge(status),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadge(String status) {
    Color color;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'APPROVED':
        color = const Color(0xff10B981);
        icon = Icons.check_circle_rounded;
        break;
      case 'REJECTED':
        color = const Color(0xffEF4444);
        icon = Icons.cancel_rounded;
        break;
      default:
        color = const Color(0xffF59E0B);
        icon = Icons.access_time_filled_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    String btnLabel,
    VoidCallback onTap,
    List<Color> gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.35),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: CustomFonts.poppins,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: gradient[0],
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              btnLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        "Application Review",
        style: TextStyle(
          color: CustomColors.clrBlack,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: CustomFonts.poppins,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: CustomColors.clrBlack,
          size: 18,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildTopStatusLabel() {
    String status = (_application?.status ?? 'SUBMITTED').toUpperCase();
    Color color = status == 'APPROVED'
        ? Colors.green
        : (status == 'REJECTED' ? Colors.red : Colors.blue);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            "CURRENT STATUS: $status",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.isEmpty) return "N/A";
    String clean = aadhaar.replaceAll(' ', '');
    if (clean.length != 12) return aadhaar;
    return "${clean.substring(0, 4)} ${clean.substring(4, 8)} ${clean.substring(8, 12)}";
  }
}
