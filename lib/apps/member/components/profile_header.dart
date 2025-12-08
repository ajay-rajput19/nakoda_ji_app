import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class ProfileHeader extends StatelessWidget {
  final String memberName;
  final String memberId;
  final String memberStatus;

  const ProfileHeader({
    super.key,
    required this.memberName,
    required this.memberId,
    required this.memberStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomColors.clrWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CustomColors.clrBtnBg.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: CustomColors.clrBtnBg, width: 2),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: CustomColors.clrBtnBg,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberName,
                  style: TextStyle(
                    color: CustomColors.clrHeading,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: CustomFonts.poppins,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Member ID : $memberId",
                  style: TextStyle(
                    color: CustomColors.clrText,
                    fontSize: 14,
                    fontFamily: CustomFonts.poppins,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColors.clrBtnBg.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CustomColors.clrBtnBg, width: 1),
                  ),
                  child: Text(
                    memberStatus,
                    style: TextStyle(
                      color: CustomColors.clrBtnBg,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: CustomFonts.poppins,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
