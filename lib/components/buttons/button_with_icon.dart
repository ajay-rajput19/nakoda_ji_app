import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class ButtonWithIcon extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? icon;
  final bool iconAtEnd;
  final bool isDisabled;
  final bool isLoading;

  const ButtonWithIcon({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.iconAtEnd = false,
    this.isDisabled = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled || isLoading ? null : onTap,
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDisabled || isLoading
              ? Colors.grey.shade400
              : CustomColors.clrBtnBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon at start
                  if (!iconAtEnd && icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],

                  // Label Text
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: CustomFonts.poppins,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  // Icon at end
                  if (iconAtEnd && icon != null) ...[const SizedBox(width: 8), icon!],
                ],
              ),
      ),
    );
  }
}
