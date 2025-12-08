import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

class ProfileRowData extends StatelessWidget {
  final String label;
  final String value;

  const ProfileRowData({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CustomColors.clrlable,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CustomColors.clrHeading,
            ),
          ),
        ],
      ),
    );
  }
}
