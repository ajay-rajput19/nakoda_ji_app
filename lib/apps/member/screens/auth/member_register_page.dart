import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/backend/member_controller.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_review_page.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_step_one.dart';
import 'package:nakoda_ji/apps/member/screens/auth/upload_document.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_status_page.dart';
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
  String? _applicationStatus;
  bool _isLoading = true;

  bool _isAlreadySubmitted() {
    if (_applicationStatus == null) return false;
    final s = _applicationStatus!.toUpperCase();
    return s != 'DRAFT' && s.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedStep();
  }

  Future<void> _loadSavedStep() async {
    setState(() => _isLoading = true);

    try {
      // 1. Check if user already has an application submitted (from backend)
      final response = await MemberController.fetchUserMembership();
      if (response.isSuccess() && response.data != null) {
        final status = (response.data['status'] ?? '').toString().toUpperCase();
        _applicationStatus = status;
        
        if (status != 'DRAFT' && status.isNotEmpty) {
          setState(() {
            _currentStep = 2; // Jump to Review/Status page
            _applicationId =
                response.data['id']?.toString() ?? response.data['_id']?.toString();
            _isLoading = false;
          });
          return;
        }
      }

      // 2. If no submitted app, check local storage for draft progress
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int savedStep = prefs.getInt(LocalStorage.memberRegistrationStep) ?? 0;
      String? savedApplicationId =
          prefs.getString(LocalStorage.memberRegistrationApplicationId);

      setState(() {
        _currentStep = savedStep;
        _applicationId = savedApplicationId;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading saved step: $e');
      setState(() => _isLoading = false);
    }
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
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: CustomColors.clrBtnBg),
        ),
      );
    }

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
                          applicationId: _applicationId,
                          onStepComplete: (String id) {
                            setState(() {
                              _applicationId = id;
                            });
                            // Save application ID to localStorage
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString(
                                LocalStorage.memberRegistrationApplicationId,
                                id,
                              );
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
                        _applicationId != null && _isAlreadySubmitted()
                            ? MemberStatusPage(
                                applicationId: _applicationId!,
                                onEdit: () {
                                  // Reset to Step 1 and allow editing
                                  setState(() {
                                    _currentStep = 0;
                                    _applicationStatus = 'DRAFT'; 
                                  });
                                },
                              )
                            : MemberReviewPage(
                                applicationId: _applicationId,
                                isReviewMode: true,
                                onEditStep: (step) => updateStep(step),
                              )
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