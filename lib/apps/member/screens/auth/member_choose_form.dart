import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_register_page.dart';
import 'package:nakoda_ji/apps/member/components/option_card.dart';
import 'package:nakoda_ji/apps/member/screens/dashboard/member_profile.dart';
import 'package:nakoda_ji/components/buttons/button_with_icon.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/utils/localStorage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberChooseForm extends StatefulWidget {
  const MemberChooseForm({super.key});

  @override
  State<MemberChooseForm> createState() => _MemberChooseFormState();
}

class _MemberChooseFormState extends State<MemberChooseForm> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadSavedSelection();
  }

  Future<void> _loadSavedSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedOption = prefs.getInt(LocalStorage.memberRegistrationSelectedOption) ?? 0;
    if (savedOption > 0) {
      setState(() {
        selectedIndex = savedOption - 1; // Convert to 0-based index
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.clrbg,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Membership Registration",
                    style: TextStyle(
                      color: CustomColors.clrBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                      fontFamily: CustomFonts.poppins,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                    // Save selection to localStorage
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setInt(LocalStorage.memberRegistrationSelectedOption, 1);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: selectedIndex == 0
                          ? CustomColors.clrBtnBg
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: OptionCard(
                      isSelected: selectedIndex == 0,
                      title: "Online Membership Form",
                      description:
                          "Complete your registration instantly through our secure online portal. Real-time validation and immediate confirmation upon submission.",
                      bulletColor: selectedIndex == 0
                          ? Colors.white
                          : CustomColors.clrForgotPass,
                      iconColor: CustomColors.clrForgotPass,
                      bullets: [
                        "Instant processing",
                        "Secure encryption",
                        "Available 24/7",
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                    // Save selection to localStorage
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setInt(LocalStorage.memberRegistrationSelectedOption, 2);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: selectedIndex == 1
                          ? CustomColors.clrBtnBg
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: selectedIndex == 1
                            ? CustomColors.clrBtnBg
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: OptionCard(
                      isSelected: selectedIndex == 1, // Pass the selected state
                      title: "Offline Form Download",
                      description:
                          "Download the PDF form to complete offline and submit at designated offices. Perfect for those who prefer traditional paper-based registration.",
                      bulletColor: selectedIndex == 1
                          ? Colors.white
                          : CustomColors.clrtempleStatusTwo,
                      iconColor: CustomColors.clrForgotPass,
                      bullets: [
                        "Printable PDF format",
                        "Submit at offices",
                        "Handwritten allowed",
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ButtonWithIcon(
                  label: "Proceed with Registration",
                  onTap: () {
                    if (selectedIndex == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select an option")),
                      );
                      return;
                    }

                    // Clear the saved option when proceeding
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.remove(LocalStorage.memberRegistrationSelectedOption);
                    });

                    if (selectedIndex == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MemberRegisterPage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MemberProfile()),
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                ),

                SizedBox(height: 10),
                Center(
                  child: Text(
                    "Please select an option above to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: CustomColors.clrText),
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