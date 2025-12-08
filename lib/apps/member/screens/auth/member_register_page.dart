import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_step_one.dart';
import 'package:nakoda_ji/apps/member/screens/auth/upload_document.dart';
import 'package:nakoda_ji/apps/member/components/step_indicator.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class MemberRegisterPage extends StatefulWidget {
  const MemberRegisterPage({super.key});

  @override
  State<MemberRegisterPage> createState() => _MemberRegisterPageState();
}

class _MemberRegisterPageState extends State<MemberRegisterPage> {
  int _currentStep = 0;

  // Method to update the current step
  void updateStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  
  void nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  // Method to go to the previous step
  void previousStep() {
    setState(() {
      _currentStep--;
    });
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
                          onStepComplete: () {
                            nextStep();
                          },
                        ),
                      if (_currentStep == 1)
                        UploadDocumentPage(
                          onStepComplete: () {
                            nextStep();
                          },
                          onBack: () {
                            previousStep();
                          },
                        ),
                      if (_currentStep == 2)
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Payment Information",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.clrHeading,
                                ),
                              ),
                            ],
                          ),
                        ),
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
