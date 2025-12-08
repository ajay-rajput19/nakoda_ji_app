import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

class SnackbarHelper {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.black87,
    int duration = 3,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: CustomColors.clrWhite),),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: duration),
      ),
    );
  }
}
