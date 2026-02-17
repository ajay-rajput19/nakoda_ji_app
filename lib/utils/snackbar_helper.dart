import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

class SnackbarHelper {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = const Color.fromARGB(221, 83, 226, 90),
    int duration = 3,
  }) {
    print('💬 [SNACKBAR] $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CustomColors.clrWhite,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: duration),
      ),
    );
  }

  static void showError(BuildContext context, {required String message}) {
    print('❌ [SNACKBAR ERROR] $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CustomColors.clrWhite,
          ),
        ),
        backgroundColor: CustomColors.clrRed,
      ),
    );
  }
}
