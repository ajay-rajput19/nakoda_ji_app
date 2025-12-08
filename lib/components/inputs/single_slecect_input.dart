import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';


class SingleSlecectInput extends StatelessWidget {
  const SingleSlecectInput({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.keyboardType,
    this.suffixIcon,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String title;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title + *
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: CustomColors.clrBlack,
                fontFamily: CustomFonts.poppins,
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

        /// Input Box
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          style: TextStyle(
            fontFamily: CustomFonts.poppins,
            fontSize: 16,
            color: CustomColors.clrInputText,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,

            hintText: hint,
            hintStyle: TextStyle(
              color: CustomColors.clrInputText,
              fontFamily: CustomFonts.poppins,
              fontWeight: FontWeight.w300,
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),

            suffixIcon: suffixIcon,

            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CustomColors.clrborder, width: 1),
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
