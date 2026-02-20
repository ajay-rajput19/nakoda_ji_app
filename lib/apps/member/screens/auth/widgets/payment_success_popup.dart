import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class PaymentSuccessPopup extends StatefulWidget {
  final String transactionId;
  final String memberName;
  final String applicationId;
  final double amount;
  final DateTime date;
  final VoidCallback onDismiss;

  const PaymentSuccessPopup({
    super.key,
    required this.transactionId,
    required this.memberName,
    required this.applicationId,
    required this.amount,
    required this.date,
    required this.onDismiss,
  });

  @override
  State<PaymentSuccessPopup> createState() => _PaymentSuccessPopupState();
}

class _PaymentSuccessPopupState extends State<PaymentSuccessPopup> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent, // Transparent for custom shadow/glow
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Main Card
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  "Payment Successful!",
                  style: TextStyle(
                    fontFamily: CustomFonts.poppins,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.clrHeading,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Welcome to the community!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: CustomFonts.poppins,
                    fontSize: 14,
                    color: CustomColors.clrText,
                  ),
                ),
                const SizedBox(height: 30),

                // Receipt Ticket Visualization
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      // Amount Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          color: CustomColors.clrtempleStatusTwo,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Total Paid",
                              style: TextStyle(
                                fontFamily: CustomFonts.poppins,
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(widget.amount),
                              style: const TextStyle(
                                fontFamily: CustomFonts.poppins,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Details Body
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildDetailRow("Member", widget.memberName),
                             const SizedBox(height: 12),
                            _buildDetailRow("App ID", "#${widget.applicationId}"),
                             const SizedBox(height: 12),
                            _buildDetailRow("Date", dateFormat.format(widget.date)),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                height: 1, 
                                color: Color(0xffCBD5E1),
                                thickness: 1,
                                indent: 10,
                                endIndent: 10,
                              ),
                            ),
                            _buildDetailRow(
                              "Ref ID", 
                              widget.transactionId, 
                              isSmall: true,
                              color: CustomColors.clrText
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Auto-redirect Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CustomColors.clrtempleStatusTwo,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Redirecting you shortly...",
                      style: TextStyle(
                        fontFamily: CustomFonts.poppins,
                        fontSize: 13,
                        color: CustomColors.clrText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Enhanced Icon Badge
          Positioned(
            top: -45,
            child: Container(
              padding: const EdgeInsets.all(4), // White rim
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff22c55e), Color(0xff16a34a)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff16a34a).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? color,
    bool isSmall = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: CustomFonts.poppins,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: CustomColors.clrText,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: CustomFonts.DMSans,
              fontSize: isSmall ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: color ?? CustomColors.clrHeading,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
