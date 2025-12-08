import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';


class Registerbtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const Registerbtn({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Width and height based on screen size
    double buttonWidth =
        screenWidth > 500
            ? MediaQuery.of(context).size.width * 0.8
            : double.infinity;
    double buttonHeight = screenWidth > 500 ? 60 : 45;

    double fontSize = screenWidth < 500 ? 14 : 18;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: buttonHeight,
        width: buttonWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),

          color: CustomColors.clrBlack,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: CustomColors.clrWhite,
              fontWeight: FontWeight.w700,
              fontFamily: CustomFonts.DMSans,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
