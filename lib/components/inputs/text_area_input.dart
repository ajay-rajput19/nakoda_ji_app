import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class TextAreaInput extends StatelessWidget {
  final String title;
  final String hint;
  final suffixIcon;
  final TextEditingController controller;

  const TextAreaInput({
    super.key,
    required this.title,
    required this.hint,
    required this.suffixIcon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: CustomColors.clrBlack,
              ),
            ),
            Text(
              " *",
              style: TextStyle(
                color: CustomColors.clrRed,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        SizedBox(height: 4),

        TextField(
          controller: controller,
          maxLines: 5,
          style: TextStyle(
            fontFamily: CustomFonts.poppins,
            fontSize: 16,
            color: CustomColors.clrInputText,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            hintStyle: TextStyle(
              color: CustomColors.clrInputText,
              fontFamily: CustomFonts.poppins,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CustomColors.clrborder),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CustomColors.clrborder, width: 1.3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}
