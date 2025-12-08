import 'package:flutter/material.dart';
import 'package:nakoda_ji/components/appbar/commen_appbar.dart';
import 'package:nakoda_ji/components/appbar/custom_drawer.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class NominationElectionEligibility extends StatefulWidget {
  const NominationElectionEligibility({super.key});

  @override
  State<NominationElectionEligibility> createState() =>
      _NominationElectionEligibilityState();
}

class _NominationElectionEligibilityState
    extends State<NominationElectionEligibility> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CommonAppBar(scaffoldKey: _scaffoldKey),
        endDrawer: CustomDrawer(),
        backgroundColor: CustomColors.clrWhite,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------- Title ----------
                Text(
                  "Nomination Application",
                  style: TextStyle(
                    color: CustomColors.clrBlack,
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    fontFamily: CustomFonts.poppins,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  "Complete your nomination details to proceed",
                  style: TextStyle(
                    color: CustomColors.clrText,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: CustomFonts.poppins,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
