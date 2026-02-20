import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/backend/member_controller.dart';
import 'package:nakoda_ji/components/appbar/custom_drawer.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';
import 'package:nakoda_ji/apps/member/screens/dashboard/member_dashboard.dart';
import 'package:nakoda_ji/components/appbar/commen_appbar.dart';
import 'package:nakoda_ji/apps/member/screens/biometric/biometric_skeleton.dart';
import 'package:table_calendar/table_calendar.dart';

class BiometricBookingPage extends StatefulWidget {
  final String membershipApplicationId;
  const BiometricBookingPage({super.key, required this.membershipApplicationId});

  @override
  State<BiometricBookingPage> createState() => _BiometricBookingPageState();
}

class _BiometricBookingPageState extends State<BiometricBookingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  List<dynamic> _schedules = [];
  Map<String, dynamic>? _existingBooking; 
  String? _error;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  Map<String, dynamic>? _selectedSlotData; // {scheduleId, slotNumber, time}

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch available slots
      final slotsResponse = await MemberController.fetchBiometricSlots(limit: 365, filter: 'upcoming'); // Fetch 365 days to cover the calendar range
      if (slotsResponse.isSuccess() && slotsResponse.data != null) {
        List<dynamic> loadedSchedules = [];
        if (slotsResponse.data['schedules'] != null) {
             loadedSchedules = slotsResponse.data['schedules'];
        } else if (slotsResponse.data['data'] != null && slotsResponse.data['data']['schedules'] != null) {
             loadedSchedules = slotsResponse.data['data']['schedules'];
        }

        // Sort schedules by date
        loadedSchedules.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));
        _schedules = loadedSchedules;
      } else {
        _error = slotsResponse.message;
      }

      // 2. Fetch existing bookings
      final bookingsResponse = await MemberController.fetchMemberBookings(widget.membershipApplicationId);
      if (bookingsResponse.isSuccess() && bookingsResponse.data != null) {
        List<dynamic> bookings = [];
        if (bookingsResponse.data['bookings'] != null) {
          bookings = bookingsResponse.data['bookings'];
        } else if (bookingsResponse.data['data'] != null && bookingsResponse.data['data']['bookings'] != null) {
           bookings = bookingsResponse.data['data']['bookings'];
        }
        
        if (bookings.isNotEmpty) {
          _existingBooking = bookings.first; 
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedSlotData == null) return;

    final date = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final time = _selectedSlotData!['time'];
    final displayTime = time.contains(':') ? time.split(':').take(2).join(':') : time;
    final scheduleId = _selectedSlotData!['scheduleId'];
    final slotNumber = _selectedSlotData!['slotNumber'];

    await showDialog(
      barrierDismissible: false, // Prevent dismissal during operation
      context: context,
      builder: (context) {
        bool isDialogLoading = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]
                ),
                child: isDialogLoading 
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(color: CustomColors.clrtempleStatusTwo),
                      const SizedBox(height: 20),
                      Text(
                        'Processing Booking...',
                        style: TextStyle(
                          fontFamily: CustomFonts.poppins,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CustomColors.clrtempleStatusTwo.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event_available_rounded, color: CustomColors.clrtempleStatusTwo, size: 32),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontFamily: CustomFonts.poppins,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CustomColors.clrHeading,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You are about to book a slot for',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: CustomFonts.poppins,
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                                const Text("DATE", style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: CustomFonts.poppins, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(_formatDate(date), style: const TextStyle(fontWeight: FontWeight.w600, color: CustomColors.clrBlack, fontFamily: CustomFonts.poppins)),
                             ],
                           ),
                           Container(width: 1, height: 30, color: Colors.grey.shade300),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                                const Text("TIME", style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: CustomFonts.poppins, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(displayTime, style: const TextStyle(fontWeight: FontWeight.w600, color: CustomColors.clrBlack, fontFamily: CustomFonts.poppins)),
                             ],
                           ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                           Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel', style: TextStyle(fontFamily: CustomFonts.poppins, color: Colors.grey, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.clrtempleStatusTwo,
                                 padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                debugPrint("🔴 BUTTON PRESSED - INITIATING BOOKING");
                                setStateDialog(() => isDialogLoading = true);
                                
                                try {
                                  final response = await MemberController.bookBiometricSlot(
                                    scheduleId: scheduleId,
                                    slotNumber: slotNumber,
                                    membershipApplicationId: widget.membershipApplicationId,
                                  );

                                  debugPrint("🔴 API RETURNED. Success: ${response.isSuccess()}");
                                  debugPrint("🔴 Message: ${response.message}");

                                  if (!mounted) return;

                                  if (response.isSuccess()) {
                                    debugPrint("✅ Booking Success: ${response.data}");
                                    Navigator.pop(context); // Close Dialog
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slot booked successfully!')));
                                    setState(() {
                                      _selectedSlotData = null; // Clear selection
                                    });
                                    _fetchData(); // Refresh UI
                                  } else {
                                    final errorMessage = response.message?.isNotEmpty == true ? response.message! : 'Unknown error occurred';
                                    debugPrint("❌ Booking Failed. Full Message: $errorMessage");
                                    setStateDialog(() => isDialogLoading = false); // Stop loading, show error
                                    
                                    // Show truncated error in SnackBar for better UX
                                    final displayError = errorMessage.length > 100 ? '${errorMessage.substring(0, 100)}...' : errorMessage;
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('Booking failed: $displayError'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 2),
                                    ));
                                  }
                                } catch (e) {
                                  debugPrint("❌ Booking Exception: $e");
                                  if (mounted) {
                                      setStateDialog(() => isDialogLoading = false);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  }
                                }
                              },
                              child: const Text('Confirm', style: TextStyle(fontFamily: CustomFonts.poppins, color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
              ),
            );
          }
        );
      }
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
      final confirmed = await showDialog<bool>(
      barrierDismissible: true,
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_schedule_send_rounded, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cancel Booking',
                style: TextStyle(
                  fontFamily: CustomFonts.poppins,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.clrHeading,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to cancel\nthis appointment?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: CustomFonts.poppins,
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                   Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Go Back', style: TextStyle(fontFamily: CustomFonts.poppins, color: Colors.grey, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                         padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes, Cancel', style: TextStyle(fontFamily: CustomFonts.poppins, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final response = await MemberController.cancelBiometricBooking(bookingId);
      if (response.isSuccess()) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
        _existingBooking = null; 
        _fetchData(); 
      } else {
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancellation failed: ${response.message}')));
         setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC), 
      endDrawer: CustomDrawer(
        isBiometricMode: true, 
        applicationId: widget.membershipApplicationId,
        isReviewMode: false,
      ),
      appBar: CommonAppBar(scaffoldKey: _scaffoldKey),
      body: _isLoading
          ? const BiometricSkeleton()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text("Error: $_error", style: const TextStyle(fontFamily: CustomFonts.poppins)),
                      TextButton(onPressed: _fetchData, child: const Text("Retry"))
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: CustomColors.clrtempleStatusTwo,
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         // Page Title
                         const Text(
                            "Biometric Schedule",
                            style: TextStyle(
                              fontFamily: CustomFonts.poppins,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: CustomColors.clrHeading,
                            ),
                         ),
                         const SizedBox(height: 24),
                         
                         if (_existingBooking != null) ...[
                           _buildHeader("Status", "You have a confirmed booking."),
                           const SizedBox(height: 24),
                           const Text(
                              "Your Booking",
                              style: TextStyle(
                                fontFamily: CustomFonts.poppins,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: CustomColors.clrBlack,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildExistingBookingCard(),
                         ] else ...[
                           _buildHeader("Select Slot", "Choose a convenient time for your visit."),
                           const SizedBox(height: 32),
                           _buildCalendarSelector(),
                           const SizedBox(height: 32),
                           _buildTimeSlotGrid(),
                           const SizedBox(height: 100), // Space for bottom button
                         ]
                      ],
                    ),
                  ),
                ),
      bottomSheet: (_existingBooking == null && !_isLoading && _selectedSlotData != null) 
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ]
              ),
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.clrtempleStatusTwo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(
                    fontFamily: CustomFonts.poppins,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CustomColors.clrtempleStatusTwo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomColors.clrtempleStatusTwo.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColors.clrtempleStatusTwo,
            CustomColors.clrtempleStatusTwo.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: CustomFonts.poppins,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: CustomFonts.poppins,
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCalendarSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ]
      ),
      padding: const EdgeInsets.all(8),
      child: TableCalendar(
        key: ValueKey(_focusedDay), // Force rebuild to fix decoration tween error
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        currentDay: DateTime.now(),
        // Enable only today and future dates
        enabledDayPredicate: (day) {
          final now = DateTime.now();
          final dayDate = DateTime(day.year, day.month, day.day);
          final todayDate = DateTime(now.year, now.month, now.day);
          return !dayDate.isBefore(todayDate);
        },
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedSlotData = null; // Clear slot selection
            });
          }
        },
        calendarStyle: CalendarStyle(
           selectedDecoration: const BoxDecoration(
             color: CustomColors.clrtempleStatusTwo,
             shape: BoxShape.rectangle,
             borderRadius: BorderRadius.all(Radius.circular(8))
           ),
           todayDecoration: BoxDecoration(
             color: CustomColors.clrtempleStatusTwo.withOpacity(0.3),
             shape: BoxShape.rectangle,
             borderRadius: const BorderRadius.all(Radius.circular(8))
           ),
           defaultTextStyle: const TextStyle(
             fontFamily: CustomFonts.poppins,
             color: Colors.black87,
             fontWeight: FontWeight.w500
           ),
           weekendTextStyle: const TextStyle(
             fontFamily: CustomFonts.poppins,
             color: Colors.black87,
             fontWeight: FontWeight.w500
           ),
           selectedTextStyle: const TextStyle(
             fontFamily: CustomFonts.poppins, 
             color: Colors.white,
             fontWeight: FontWeight.bold
           ),
           todayTextStyle: TextStyle(
             fontFamily: CustomFonts.poppins, 
             color: CustomColors.clrtempleStatusTwo,
             fontWeight: FontWeight.bold
           ),
           disabledTextStyle: const TextStyle(
             fontFamily: CustomFonts.poppins, 
             color: Colors.grey
           ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontFamily: CustomFonts.poppins,
            fontWeight: FontWeight.bold,
            fontSize: 16
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.grey),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    if (_selectedDay == null) return const SizedBox.shrink();
    
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);

    final schedule = _schedules.firstWhere(
      (s) {
        final sDate = s['date'];
        if (sDate == null) return false;
        if (sDate == selectedDateStr) return true;
        try {
           return DateFormat('yyyy-MM-dd').format(DateTime.parse(sDate)) == selectedDateStr;
        } catch (_) {
           return false;
        }
      }, 
      orElse: () => null
    );

    if (schedule == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(Icons.event_note, color: Colors.grey.shade300, size: 50),
              const SizedBox(height: 10),
              Text(
                "No slots available on this date",
                style: TextStyle(color: Colors.grey.shade400, fontFamily: CustomFonts.poppins),
              )
            ],
          ),
        ),
      );
    }

    final timeSlots = schedule['timeSlots'] as List<dynamic>? ?? [];

    if (timeSlots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(Icons.event_busy, color: Colors.grey.shade300, size: 50),
              const SizedBox(height: 10),
              Text(
                "No slots available",
                style: TextStyle(color: Colors.grey.shade400, fontFamily: CustomFonts.poppins),
              )
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             const Text(
              "Available Time Slots",
              style: TextStyle(
                fontFamily: CustomFonts.poppins,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CustomColors.clrHeading,
              ),
            ),
             Text(
              DateFormat('MMM d, yyyy').format(_selectedDay!),
              style: const TextStyle(
                fontFamily: CustomFonts.poppins,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns like in the design
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            final slot = timeSlots[index];
            final isBooked = slot['isBooked'] ?? false;
            final startTime = slot['startTime'] ?? '';
            final slotNumber = slot['slotNumber'];
            
            final isSelected = _selectedSlotData != null && 
                               _selectedSlotData!['slotNumber'] == slotNumber &&
                               _selectedSlotData!['scheduleId'] == schedule['id'];

            Color bgColor = const Color(0xffDCFCE7); // Default Green (Available)
            Color textColor = const Color(0xff166534);
            Color borderColor = Colors.transparent;
            String statusText = "Available";

            if (isBooked) {
              bgColor = const Color(0xffFEF2F2); // Red (Booked)
              textColor = const Color(0xff991B1B);
              statusText = "Booked";
            } else if (isSelected) {
              bgColor = const Color(0xff3B82F6); // Blue (Selected)
              textColor = Colors.white;
              statusText = "Selected";
            } else {
               // Available state
               bgColor = const Color(0xffF0FDF4);
               textColor = const Color(0xff15803D);
               borderColor = const Color(0xffBBF7D0);
            }

            return GestureDetector(
              onTap: isBooked ? null : () {
                setState(() {
                  _selectedSlotData = {
                    'scheduleId': schedule['id'],
                    'slotNumber': slotNumber,
                    'time': startTime,
                  };
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xff3B82F6).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4)
                    )
                  ] : []
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startTime.contains(':') ? startTime.split(':').take(2).join(':') : startTime,
                      style: TextStyle(
                        fontFamily: CustomFonts.poppins,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontFamily: CustomFonts.poppins,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textColor.withOpacity(isBooked || isSelected ? 0.9 : 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExistingBookingCard() {
    final booking = _existingBooking!;
    final date = booking['date'] ?? 'N/A';
    final time = booking['startTime'] ?? 'N/A';
    final id = booking['id'] ?? '';

    // Logic to separate date components if needed, or just display as is.
    // Assuming date is in a standard format, we can try to parse it to make it look nice.
    String day = "";
    String month = ""; 
    String weekday = "";

    try {
      final  dt = DateTime.parse(date); // Adjust based on actual date format string
      day = DateFormat('d').format(dt);
      month = DateFormat('MMM').format(dt);
      weekday = DateFormat('EEEE').format(dt);
    } catch(e) {
      day = date;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Top Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date Box
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontFamily: CustomFonts.poppins,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      Text(
                        month.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: CustomFonts.poppins,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weekday.isNotEmpty ? weekday : "Scheduled Date",
                        style: const TextStyle(
                          fontFamily: CustomFonts.poppins,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                       "$time",
                        style: const TextStyle(
                          fontFamily: CustomFonts.poppins,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CustomColors.clrBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Confirmed",
                          style: TextStyle(
                            fontFamily: CustomFonts.poppins,
                            color: Color(0xFF15803D),
                            fontSize: 11,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          // Bottom Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
               width: double.infinity,
               child: OutlinedButton(
                 onPressed: () => _cancelBooking(id),
                 style: OutlinedButton.styleFrom(
                   foregroundColor: Colors.red,
                   side: const BorderSide(color: Colors.redAccent),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   padding: const EdgeInsets.symmetric(vertical: 14),
                 ),
                 child: const Text(
                   "Cancel Appointment",
                   style: TextStyle(
                     fontFamily: CustomFonts.poppins,
                     fontWeight: FontWeight.w600,
                   ),
                 ),
               ),
            ),
          )
        ],
      ),
    );
  }
}
