import 'package:flutter/material.dart';
import 'package:nakoda_ji/backend/models/booking_model.dart';
import 'package:nakoda_ji/apps/member/components/booking_crad_list.dart';
import 'package:nakoda_ji/components/appbar/commen_appbar.dart';
import 'package:nakoda_ji/components/appbar/custom_drawer.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/apps/member/backend/member_controller.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final String? applicationId;
  final bool? isReviewMode;
  final bool? isBiometricMode;

  const BookingPage({
    super.key,
    this.applicationId,
    this.isReviewMode = false,
    this.isBiometricMode = false,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  List<BookingModel> _bookings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? applicationId = widget.applicationId;

      if (applicationId == null) {
        // 1. Fetch User Membership to get Application ID
        debugPrint("🔍 [BookingPage] No ApplicationID provided, fetching from API...");
        final userMembershipResponse = await MemberController.fetchUserMembership();
        
        if (!userMembershipResponse.isSuccess() || userMembershipResponse.data == null) {
          debugPrint("❌ [BookingPage] userMembershipResponse failed: ${userMembershipResponse.message}");
          throw Exception("Could not fetch membership details. Please try again.");
        }

        final membershipData = userMembershipResponse.data;
        
        // Handle different possible structures of the response
        if (membershipData is Map<String, dynamic>) {
          if (membershipData.containsKey('_id')) {
            applicationId = membershipData['_id'];
          } else if (membershipData.containsKey('data')) {
             final innerData = membershipData['data'];
             if (innerData is Map<String, dynamic> && innerData.containsKey('_id')) {
               applicationId = innerData['_id'];
             }
          } else if (membershipData.containsKey('application')) {
              final appData = membershipData['application'];
              if (appData is Map<String, dynamic> && appData.containsKey('_id')) {
                applicationId = appData['_id'];
              }
          }
        } else if (membershipData is List && membershipData.isNotEmpty) {
             final firstItem = membershipData[0];
             if (firstItem is Map<String, dynamic> && firstItem.containsKey('_id')) {
               applicationId = firstItem['_id'];
             }
        }
      }

      if (applicationId == null) {
        throw Exception("Membership Application ID not found.");
      }

      debugPrint("✅ [BookingPage] Using ApplicationID: $applicationId");

      // 2. Fetch Bookings using Application ID
      final bookingsResponse = await MemberController.fetchMemberBookings(applicationId);

      if (!bookingsResponse.isSuccess()) {
        throw Exception(bookingsResponse.message ?? "Failed to fetch bookings.");
      }

      List<dynamic> bookingsList = [];
      if (bookingsResponse.data is Map<String, dynamic>) {
         final data = bookingsResponse.data;
         if (data['bookings'] != null) {
            bookingsList = data['bookings'];
         } else if (data['data'] != null && data['data'] is Map && data['data']['bookings'] != null) {
            bookingsList = data['data']['bookings'];
         }
      }

      // 3. Map to BookingModel
      List<BookingModel> mappedBookings = [];
      
      for (var b in bookingsList) {
        final dateStr = b['date'] ?? '';
        final timeStr = b['startTime'] ?? '';
        
        String formattedDate = dateStr;
        try {
          final date = DateTime.parse(dateStr);
          formattedDate = DateFormat('MMMM d, yyyy').format(date);
        } catch (_) {}

        mappedBookings.add(BookingModel(
          title: "Biometric Appointment",
          date: formattedDate,
          time: timeStr,
          description: "Confirmed slot for biometric verification.",
          duration: "30 Mins", 
          status: "Confirmed",
          statusColor: const Color(0xff15803D), // Green
          bgColor: Colors.white,
        ));
      }

      if (mounted) {
        setState(() {
          _bookings = mappedBookings;
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
      debugPrint("Error fetching bookings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CommonAppBar(scaffoldKey: _scaffoldKey),
        endDrawer: CustomDrawer(
          isReviewMode: widget.isReviewMode ?? false,
          isBiometricMode: widget.isBiometricMode ?? false,
          applicationId: widget.applicationId,
        ),
        backgroundColor: CustomColors.clrbg,
        body: RefreshIndicator(
          onRefresh: _fetchBookings,
          color: CustomColors.clrtempleStatusTwo,
          child: Column(
            children: [
               Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  "All Bookings",
                  style: TextStyle(
                    color: CustomColors.clrBlack,
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    fontFamily: CustomFonts.poppins,
                  ),
                ),
               ),
               Expanded(
                 child: _buildContent(),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: CustomColors.clrtempleStatusTwo),
      );
    }

    if (_error != null) {
      return Center(
        child: SingleChildScrollView( // To handle overflow if error is long
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                "Error loading bookings",
                style: TextStyle(
                  fontFamily: CustomFonts.poppins,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!.replaceAll("Exception: ", ""),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: CustomFonts.poppins,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchBookings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.clrtempleStatusTwo,
                ),
                child: const Text("Retry", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No bookings available",
              style: TextStyle(
                fontSize: 16,
                color: CustomColors.clrText,
                fontFamily: CustomFonts.poppins,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: SectionCradList(
            booking: _bookings[index],
          ),
        );
      },
    );
  }
}
