import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nakoda_ji/apps/user/backend/user_auth_controller.dart';
import 'package:nakoda_ji/apps/user/screens/auth/otp_verify.dart';
import 'package:nakoda_ji/apps/user/screens/auth/user_Login.dart';
import 'package:nakoda_ji/apps/user/screens/components/AuthTopWidget.dart';
import 'package:nakoda_ji/backend/models/user_model.dart';
import 'package:nakoda_ji/components/buttons/primary_btn.dart';
import 'package:nakoda_ji/components/inputs/primary_input.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';
import 'package:nakoda_ji/utils/snackbar_helper.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  
  bool _isPasswordVisible = false;

  bool _isLoading = false;
  String errorMessage = '';
  String successMessage = '';

  bool _validateInputs() {
    setState(() {
      errorMessage = '';
      successMessage = '';
    });

    if (nameCtrl.text.trim().isEmpty) {
      _showError('Name is required');
      return false;
    }

    if (emailCtrl.text.trim().isEmpty) {
      _showError('Email is required');
      return false;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailCtrl.text.trim())) {
      _showError('Please enter a valid email address');
      return false;
    }

    if (mobileCtrl.text.trim().isEmpty) {
      _showError('Mobile number is required');
      return false;
    }

    if (mobileCtrl.text.trim().length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(mobileCtrl.text.trim())) {
      _showError('Please enter a valid 10-digit mobile number');
      return false;
    }

    if (passwordCtrl.text.trim().isEmpty) {
      _showError('Password is required');
      return false;
    }

    if (passwordCtrl.text.trim().length < 8) {
      _showError('Password should be at least 8 characters');
      return false;
    }

    if (!RegExp(r'[A-Z]').hasMatch(passwordCtrl.text)) {
      _showError('Password should contain at least 1 uppercase letter');
      return false;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(passwordCtrl.text)) {
      _showError('Password should contain at least 1 special character');
      return false;
    }

    return true;
  }

  Future<void> _handleRegister() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    final user = UserModel(
      id: '',
      firstName: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      phone: mobileCtrl.text.trim(),
      password: passwordCtrl.text,
    );

    try {
      final result = await UserAuthController.handleRegister(user);

      setState(() {
        _isLoading = false;
      });

      if (result == 'success') {
        _showSuccess(
          'Registration successful! Please check your email for verification code.',
        );

        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            AppNavigation(
              context,
            ).pushReplacement(OtpVerify(email: emailCtrl.text.trim()));
          }
        });
      } else {
        _showError(result);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('An error occurred during registration');
    }
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
    SnackbarHelper.show(context, message: message, backgroundColor: Colors.red);
  }

  void _showSuccess(String message) {
    setState(() {
      successMessage = message;
    });
    SnackbarHelper.show(
      context,
      message: message,
      backgroundColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffE5E5E5),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: BoxDecoration(
              color: CustomColors.clrWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AuthTopWidget(title: "Sign Up"),
                  SizedBox(height: 15),
                  PrimaryInput(
                    title: "Full Name",
                    hint: "Enter your full name",
                    controller: nameCtrl,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 14),

                  PrimaryInput(
                    title: "Email",
                    hint: "Enter your email",
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  PrimaryInput(
                    title: "Mobile Number",
                    hint: "Enter mobile number",
                    controller: mobileCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryInput(
                        title: "Password",
                        hint: "Enter password",
                        controller: passwordCtrl,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: CustomColors.clrForgotPass,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'At least 8 characters, 1 uppercase letter, 1 special character',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  PrimaryButton(
                    label: _isLoading ? "Registering..." : "Register",
                    onTap: _isLoading ? () {} : () => _handleRegister(),
                  ),

                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.black87, fontSize: 15),
                      ),
                      GestureDetector(
                        onTap: () {
                          AppNavigation(context).push(UserLogin());
                        },
                        child: Text(
                          " Login",
                          style: TextStyle(
                            color: CustomColors.clrBtnBg,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}