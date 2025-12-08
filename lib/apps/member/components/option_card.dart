import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

class OptionCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> bullets;
  final Color bulletColor;
  final Color iconColor;
  final bool isSelected; 

  const OptionCard({
    required this.title,
    required this.description,
    required this.bullets,
    required this.bulletColor,
    required this.iconColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    List<IconData> bulletIcons = [
      Icons.flash_on,
      Icons.lock,
      Icons.access_time,
    ];

    List<IconData> bulletIcons2 = [
      Icons.picture_as_pdf,
      Icons.location_on,
      Icons.edit,
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFffffff),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.laptop, size: 28, color: iconColor),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : CustomColors.clrHeading,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white70 : CustomColors.clrText,
            ),
          ),

          const SizedBox(height: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(bullets.length, (index) {
              IconData icon;
              if (title.contains("Online")) {
                icon = index < bulletIcons.length
                    ? bulletIcons[index]
                    : Icons.check;
              } else {
                icon = index < bulletIcons2.length
                    ? bulletIcons2[index]
                    : Icons.check;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18, color: bulletColor),
                    const SizedBox(width: 8),
                    Text(
                      bullets[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : CustomColors.clrText,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
