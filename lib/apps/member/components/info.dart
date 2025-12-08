import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

enum InfoDotType { green, blue, orange }

class InfoItemRow extends StatelessWidget {
  final String title;
  final String? value;
  final String? time;
  final InfoDotType? dot;
  final IconData? icon;

  const InfoItemRow({
    super.key,
    required this.title,
    this.value,
    this.time,
    this.dot,
    this.icon,
  });

  Color _getDotColor() {
    switch (dot) {
      case InfoDotType.green:
        return CustomColors.clrtempleStatusTwo; // green
      case InfoDotType.blue:
        return CustomColors.clrForgotPass; // blue
      case InfoDotType.orange:
        return CustomColors.clrtempleStatus; // orange
      default:
        return CustomColors.clrText; // default icon/text color
    }
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = _getDotColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// DOT
          if (dot != null)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 6, right: 10),
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),

          /// ICON (same color as dot)
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                icon,
                size: 20,
                color: dotColor,
              ),
            ),

          /// TITLE + TIME
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CustomColors.clrText,
                  ),
                ),
                if (time != null)
                  Text(
                    time!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CustomColors.clrText,
                    ),
                  ),
              ],
            ),
          ),

          /// VALUE (right side)
          if (value != null)
            Text(
              value!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: CustomColors.clrText,
              ),
            ),
        ],
      ),
    );
  }
}
