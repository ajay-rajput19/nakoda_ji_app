import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

class HeaderRow extends StatelessWidget {
  final IconData headerIcon;
  final Color headerBgColor;
  final Color iconColor;
  final String title;
  final String actionText;
  final VoidCallback? onActionTap;

  const HeaderRow({
    super.key,
    required this.headerIcon,
    required this.headerBgColor,
    required this.iconColor,
    required this.title,
    this.actionText = "",
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: headerBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(headerIcon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 12),

        /// Title
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CustomColors.clrHeading,
            ),
          ),
        ),

        /// Action Button (like "View All")
        if (actionText.isNotEmpty)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style: const TextStyle(
                color: CustomColors.clrTextBtn,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
