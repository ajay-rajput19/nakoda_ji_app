import 'package:flutter/material.dart';
import 'package:nakoda_ji/components/appbar/commen_appbar.dart';
import 'package:nakoda_ji/components/appbar/custom_drawer.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class ScheduleBiometric extends StatefulWidget {
  const ScheduleBiometric({super.key});

  @override
  State<ScheduleBiometric> createState() => _ScheduleBiometricState();
}

class _ScheduleBiometricState extends State<ScheduleBiometric> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CommonAppBar(scaffoldKey: _scaffoldKey),
        endDrawer: CustomDrawer(),
        backgroundColor: CustomColors.clrbg,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            // color: CustomColors.clrWhite,
            borderRadius: BorderRadius.circular(10),
          ),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashbaord",
                  style: TextStyle(
                    color: CustomColors.clrBlack,
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    fontFamily: CustomFonts.poppins,
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
