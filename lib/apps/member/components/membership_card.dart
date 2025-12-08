import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class MembershipCard extends StatelessWidget {
  final String memberName;
  final String memberId;
  final String issueDate;
  final String expiryDate;

  const MembershipCard({
    super.key,
    required this.memberName,
    required this.memberId,
    required this.issueDate,
    required this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColors.clrBtnBg,
            CustomColors.clrBtnBg.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: CustomColors.clrBtnBg.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MEMBERSHIP CARD",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: CustomFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nakoda Ji Temple",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: CustomFonts.poppins,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
          ),

          // Card Body
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Member Name
                Text(
                  memberName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: CustomFonts.poppins,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Member ID
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    memberId,
                    style: TextStyle(
                      color: CustomColors.clrBtnBg,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: CustomFonts.poppins,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // QR Code Placeholder
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code,
                        size: 70,
                        color: CustomColors.clrBtnBg,
                      ),
                      Text(
                        "Scan QR Code",
                        style: TextStyle(
                          color: CustomColors.clrBtnBg,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Validity Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ISSUE DATE",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: CustomFonts.poppins,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          issueDate,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: CustomFonts.poppins,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "EXPIRY DATE",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: CustomFonts.poppins,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expiryDate,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: CustomFonts.poppins,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}