import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_review_page.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_step_one.dart';
import 'package:nakoda_ji/apps/member/screens/auth/upload_document.dart';
import 'package:nakoda_ji/apps/member/components/step_indicator.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/utils/localStorage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberRegisterPage extends StatefulWidget {
  const MemberRegisterPage({super.key});

  @override
  State<MemberRegisterPage> createState() => _MemberRegisterPageState();
}

class _MemberRegisterPageState extends State<MemberRegisterPage> {
  int _currentStep = 0;
  String? _applicationId;

  @override
  void initState() {
    super.initState();
    _loadSavedStep();
  }

  Future<void> _loadSavedStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedStep = prefs.getInt(LocalStorage.memberRegistrationStep) ?? 0;
    String? savedApplicationId = prefs.getString(LocalStorage.memberRegistrationApplicationId);
    
    setState(() {
      _currentStep = savedStep;
      _applicationId = savedApplicationId;
    });
  }

  // Method to update the current step
  void updateStep(int step) {
    setState(() {
      _currentStep = step;
    });
    // Save step to localStorage
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(LocalStorage.memberRegistrationStep, step);
    });
  }

  void nextStep() {
    setState(() {
      _currentStep++;
    });
    // Save step to localStorage
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(LocalStorage.memberRegistrationStep, _currentStep);
    });
  }

  // Method to go to the previous step
  void previousStep() {
    setState(() {
      _currentStep--;
    });
    // Save step to localStorage
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(LocalStorage.memberRegistrationStep, _currentStep);
    });
  }

  // Method to clear saved step data (when registration is completed)
  static Future<void> _clearSavedStepData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(LocalStorage.memberRegistrationStep);
    await prefs.remove(LocalStorage.memberRegistrationApplicationId);
    await prefs.remove(LocalStorage.memberRegistrationSelectedOption);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                "Membership Form",
                style: TextStyle(
                  color: CustomColors.clrBlack,
                  fontWeight: FontWeight.w500,
                  fontSize: 25,
                  fontFamily: CustomFonts.poppins,
                ),
              ),
              const SizedBox(height: 20),
              // Step Indicator - always visible at the top
              FixedStepIndicator(currentStep: _currentStep),
              const SizedBox(height: 20),
              // Step Content - changes based on current step
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0)
                        MemberStepOne(
                          onStepComplete: (String id) {
                            setState(() {
                              _applicationId = id;
                            });
                            // Save application ID to localStorage
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString(LocalStorage.memberRegistrationApplicationId, id);
                            });
                            nextStep();
                          },
                        ),
                      if (_currentStep == 1)
                        UploadDocumentPage(
                          applicationId: _applicationId ?? '',
                          onStepComplete: () {
                            nextStep();
                          },
                          onBack: () {
                            previousStep();
                          },
                        ),
                      if (_currentStep == 2)
                        MemberReviewPage(applicationId: _applicationId)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}