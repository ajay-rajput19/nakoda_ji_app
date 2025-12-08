import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/user/screens/auth/otp_verify.dart';
import 'package:nakoda_ji/apps/user/screens/components/AuthTopWidget.dart';
import 'package:nakoda_ji/components/buttons/primary_btn.dart';
import 'package:nakoda_ji/components/inputs/primary_input.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/apps/user/backend/user_auth_controller.dart';
import 'package:nakoda_ji/utils/snackbar_helper.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleForgotPassword() async {
    if (emailCtrl.text.isEmpty) {
      SnackbarHelper.show(context, message: 'Email is required', backgroundColor: Colors.red);
      return;
    }
    
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailCtrl.text)) {
      SnackbarHelper.show(context, message: 'Please enter a valid email address', backgroundColor: Colors.red);
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await UserAuthController.handleForgotPassword(emailCtrl.text.trim());
      
      setState(() {
        _isLoading = false;
      });
      
      if (result == 'success') {
        SnackbarHelper.show(context, message: 'Password reset instructions sent to your email!', backgroundColor: Colors.green);
        
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            AppNavigation(context).push(OtpVerify(email: emailCtrl.text.trim(), isForgotPassword: true));
          }
        });
      } else {
        SnackbarHelper.show(context, message: result, backgroundColor: Colors.red);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      SnackbarHelper.show(context, message: 'An error occurred while processing your request', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.clrbg,
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
                  AuthTopWidget(title: "Password Forgot"),
                  PrimaryInput(
                    title: "Email",
                    hint: "Enter your email",
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),

                  PrimaryButton(
                    label: _isLoading ? "Sending..." : "Send Reset Instructions",
                    onTap: _isLoading ? () {} : _handleForgotPassword,
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}