import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';


class SingleInputComponent extends StatelessWidget {
  const SingleInputComponent({
    super.key,
    required this.title,
    required this.controller,
    required this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius = 10.0,
    this.showTitle = true,
    this.backClr,
    this.gradient,
    this.minLines,
    this.maxLines,
    this.errorText,
    this.onChanged,
  });

  final String? title;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double borderRadius;
  final bool showTitle;
  final Color? backClr;
  final Gradient? gradient;
  final int? minLines;
  final int? maxLines;
  final String? errorText;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Width and height based on screen size
    double padding = screenWidth > 500 ? 20 : 10;

    double fontSize = screenWidth < 500 ? 14 : 18;
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle && title != null && title!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: fontSize,
                  fontFamily: CustomFonts.poppins,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.clrWhite,
                ),
              ),
            ),
            // SizedBox(height: 5),
          ],
          SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            minLines: minLines,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: screenWidth < 500 ? 13 : 17,
              color: CustomColors.clrWhite,
              fontWeight: FontWeight.w400,
              fontFamily: CustomFonts.poppins,
            ),
            onChanged: (value) {
              onChanged?.call(value);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: backClr ?? Colors.transparent,
              hintText: title ?? 'Enter',
              hintStyle: TextStyle(
                fontWeight: FontWeight.w300,
                color: CustomColors.clrWhite,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: CustomColors.clrWhite, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: CustomColors.clrWhite, width: 1),
              ),
              contentPadding: EdgeInsets.all(padding),
              prefixIcon: prefixIcon, 
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                errorText!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
