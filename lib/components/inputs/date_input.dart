import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class DateInput extends StatelessWidget {
  const DateInput({
    super.key,
    required this.title,
    required this.controller,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.suffixIcon,
  });

  final String title;
  final TextEditingController controller;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Widget? suffixIcon;

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
        const SizedBox(height: 4),
        // -------- Input Box --------
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: CustomColors.clrBtnBg, // Use primary color
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: CustomColors.clrBlack,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              controller.text = DateFormat('yyyy-MM-dd').format(picked);
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              readOnly: true,
              style: TextStyle(
                fontFamily: CustomFonts.poppins,
                fontSize: 16,
                color: CustomColors.clrInputText,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                suffixIcon: suffixIcon,
                hintText: 'Select your date',
                hintStyle: TextStyle(
                  color: CustomColors.clrInputText,
                  fontFamily: CustomFonts.poppins,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: CustomColors.clrborder,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: CustomColors.clrborder,
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
