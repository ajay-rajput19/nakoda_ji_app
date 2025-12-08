import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

class DocumentCard extends StatelessWidget {
  final IconData icon;

  final String title;
  final String subtitle;
  final String status;
  final Color iconColor;
  final IconData statusIcon;

  const DocumentCard({
    super.key,
    required this.icon,

    required this.title,
    required this.subtitle,
    required this.status,
    required this.iconColor,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (status.toLowerCase() == 'verified') {
      statusColor = CustomColors.clrtempleStatusTwo;
    } else if (status.toLowerCase() == 'pending') {
      statusColor = CustomColors.clrStatusPending;
    } else {
      statusColor = CustomColors.clrText;
    }
    Color iconBg;
    if (status.toLowerCase() == 'verified') {
      iconBg = CustomColors.clrCradBg;
    } else if (status.toLowerCase() == 'pending') {
      iconBg = CustomColors.clrCradbgTwo;
    } else {
      iconBg = CustomColors.clrCradBg;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: statusColor, size: 26),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CustomColors.clrHeading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: CustomColors.clrText),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
