import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/asset_exports.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

class AuthTopWidget extends StatelessWidget {
  final String title;
  final double logoHeight;

  const AuthTopWidget({super.key, required this.title, this.logoHeight = 70});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          AssetExports.loginImg,
          height: logoHeight,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 10),

        // ---------------- TITLE ----------------
        Text(
          title,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            fontFamily: CustomFonts.fontInter,
            color: CustomColors.clrBlack,
          ),
        ),
      ],
    );
  }
}
