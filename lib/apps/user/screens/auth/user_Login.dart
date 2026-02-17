import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_choose_form.dart';
import 'package:nakoda_ji/apps/member/screens/dashboard/member_dashboard.dart';
import 'package:nakoda_ji/apps/user/screens/auth/forgot_password.dart';
import 'package:nakoda_ji/apps/user/screens/auth/user_Signup.dart';
import 'package:nakoda_ji/apps/user/screens/components/AuthTopWidget.dart';
import 'package:nakoda_ji/components/buttons/primary_btn.dart';
import 'package:nakoda_ji/components/inputs/primary_input.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';
import 'package:nakoda_ji/apps/user/backend/user_auth_controller.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_register_page.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_status_page.dart';
import 'package:nakoda_ji/utils/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool _isPasswordVisible = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    passwordCtrl.clear();
  }

  Future<void> _handleLogin() async {
    if (emailCtrl.text.isEmpty) {
      SnackbarHelper.show(
        context,
        message: 'Email is required',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (passwordCtrl.text.isEmpty) {
      SnackbarHelper.show(
        context,
        message: 'Password is required',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await UserAuthController.handleLogin(
        emailCtrl.text.trim(),
        passwordCtrl.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        String role = result['role'] ?? 'user';

        SnackbarHelper.show(
          context,
          message: 'Login successful!',
          backgroundColor: Colors.green,
        );

        Future.delayed(Duration(seconds: 1), () async {
          if (mounted) {
            final bool hasApp = result['hasMembershipApplication'] ?? false;
            final String? appId = result['membershipApplicationId'];

            if (role.toLowerCase() == 'member') {
              AppNavigation(context).pushReplacement(MemberDashboard());
            } else if (hasApp && appId != null) {
              // Redirect directly to Status Page if application exists
              AppNavigation(context).pushReplacement(
                MemberStatusPage(
                  applicationId: appId,
                  onEdit: () {
                    AppNavigation(context).pushReplacement(
                      const MemberRegisterPage(),
                    );
                  },
                ),
              );
            } else {
              // If no application, take them to choice form
              AppNavigation(context).pushReplacement(MemberChooseForm());
            }
          }
        });
      } else {
        SnackbarHelper.show(
          context,
          message: result['message'],
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      SnackbarHelper.show(
        context,
        message: 'An error occurred during login',
        backgroundColor: Colors.red,
      );
    }
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
                  AuthTopWidget(title: "Log In"),

                  PrimaryInput(
                    title: "Email",
                    hint: "Enter your email",
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 14),

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
                        color: CustomColors.clrBtnBg,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        AppNavigation(context).push(ForgotPassword());
                      },
                      child: Text(
                        " Forgot Password ?",
                        style: TextStyle(
                          color: CustomColors.clrForgotPass,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  PrimaryButton(
                    label: "Login",
                    isLoading: _isLoading,
                    onTap: _isLoading ? () {} : _handleLogin,
                  ),
                  SizedBox(height: 14),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Don’t have an account?",
                        style: TextStyle(color: Colors.black87, fontSize: 15),
                      ),
                      GestureDetector(
                        onTap: () {
                          AppNavigation(context).push(SignUpPage());
                        },
                        child: Text(
                          " Sign Up",
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
