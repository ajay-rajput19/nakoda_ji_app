import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/nomination/screens/nomination_election_eligibility.dart';
import 'package:nakoda_ji/components/appbar/commen_appbar.dart';
import 'package:nakoda_ji/components/appbar/custom_drawer.dart';
import 'package:nakoda_ji/components/buttons/button_with_icon.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';

class NominationAppliction extends StatefulWidget {
  const NominationAppliction({super.key});

  @override
  State<NominationAppliction> createState() => _NominationApplictionState();
}

class _NominationApplictionState extends State<NominationAppliction> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedValue = "Trustee"; // <-- required dropdown variable

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

                SizedBox(height: 20),

                /// ---------- Label ----------
                Text(
                  "Select what you want to apply for?",
                  style: TextStyle(
                    color: CustomColors.clrText,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    fontFamily: CustomFonts.poppins,
                  ),
                ),

                SizedBox(height: 10),

                /// ---------- Dropdown ----------
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedValue,
                      icon: Icon(Icons.keyboard_arrow_down),
                      dropdownColor: Colors.white,
                      items: [
                        DropdownMenuItem(
                          value: "Trustee",
                          child: Text(
                            "Trustee",
                            style: TextStyle(
                              fontFamily: CustomFonts.poppins,
                              fontSize: 15,
                              color: CustomColors.clrHeading,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Committee",
                          child: Text(
                            "Committee",
                            style: TextStyle(
                              fontFamily: CustomFonts.poppins,
                              fontSize: 15,
                              color: CustomColors.clrHeading,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value!;
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: 30),

                ButtonWithIcon(
                  label: "Do eligibilty Check",
                  icon: Icon(Icons.arrow_right),
                  onTap: () {
                    AppNavigation(
                      context,
                    ).push(NominationElectionEligibility());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
