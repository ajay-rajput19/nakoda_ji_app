import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class PaymentFailedPopup extends StatefulWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const PaymentFailedPopup({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  State<PaymentFailedPopup> createState() => _PaymentFailedPopupState();
}

class _PaymentFailedPopupState extends State<PaymentFailedPopup> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onCancel(); // Trigger cancel callback to close
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent, 
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
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
                const Text(
                  "Payment Failed",
                  style: TextStyle(
                    fontFamily: CustomFonts.poppins,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.clrBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Transaction could not be completed.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: CustomFonts.poppins,
                    fontSize: 14,
                    color: CustomColors.clrText,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Error Details Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xffFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffFECACA)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.priority_high_rounded,
                          color: CustomColors.clrRed,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Error Details",
                              style: TextStyle(
                                fontFamily: CustomFonts.poppins,
                                fontSize: 12,
                                color: CustomColors.clrRed.withOpacity(0.8),
                                fontWeight: FontWeight.w600
                              ),
                            ),
                             const SizedBox(height: 4),
                            Text(
                              widget.errorMessage,
                              style: const TextStyle(
                                fontFamily: CustomFonts.DMSans,
                                fontSize: 13,
                                color: CustomColors.clrRed,
                                fontWeight: FontWeight.w500
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Auto-close Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CustomColors.clrRed,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Closing shortly...",
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
          
          // Failed Icon Badge
          Positioned(
            top: -45,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, CustomColors.clrRed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CustomColors.clrRed.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
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
}
