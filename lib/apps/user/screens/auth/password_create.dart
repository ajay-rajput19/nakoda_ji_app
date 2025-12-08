import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/user/screens/auth/user_Login.dart';
import 'package:nakoda_ji/apps/user/screens/components/AuthTopWidget.dart';
import 'package:nakoda_ji/components/buttons/primary_btn.dart';
import 'package:nakoda_ji/components/inputs/primary_input.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';
import 'package:nakoda_ji/apps/user/backend/user_auth_controller.dart';
import 'package:nakoda_ji/utils/snackbar_helper.dart';

class PasswordCreate extends StatefulWidget {
  final String token;

  const PasswordCreate({super.key, required this.token});

  @override
  State<PasswordCreate> createState() => _PasswordCreateState();
}

class _PasswordCreateState extends State<PasswordCreate> {
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleCreatePassword() async {
    if (passwordCtrl.text.isEmpty) {
      SnackbarHelper.show(context, message: 'Password is required', backgroundColor: Colors.red);
      return;
    }
    
    if (confirmPasswordCtrl.text.isEmpty) {
      SnackbarHelper.show(context, message: 'Confirm password is required', backgroundColor: Colors.red);
      return;
    }
    
    if (passwordCtrl.text != confirmPasswordCtrl.text) {
      SnackbarHelper.show(context, message: 'Passwords do not match', backgroundColor: Colors.red);
      return;
    }
    
    if (passwordCtrl.text.length < 8) {
      SnackbarHelper.show(context, message: 'Password must be at least 8 characters long', backgroundColor: Colors.red);
      return;
    }
    
    if (!passwordCtrl.text.contains(RegExp(r'[A-Z]'))) {
      SnackbarHelper.show(context, message: 'Password must contain at least one uppercase letter', backgroundColor: Colors.red);
      return;
    }
    
    if (!passwordCtrl.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      SnackbarHelper.show(context, message: 'Password must contain at least one special character', backgroundColor: Colors.red);
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await UserAuthController.handleCreatePassword(
        widget.token,
        passwordCtrl.text,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (result == 'success') {
        SnackbarHelper.show(context, message: 'Password created successfully!', backgroundColor: Colors.green);
        
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            AppNavigation(context).pushReplacement(UserLogin());
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
                  AuthTopWidget(title: "Create Password"),
                  
                  PrimaryInput(
                    title: "Password",
                    hint: "Enter password",
                    controller: passwordCtrl,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 14),
                  PrimaryInput(
                    title: "Confirm Password",
                    hint: "Confirm password",
                    controller: confirmPasswordCtrl,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 14),

                  const SizedBox(height: 20),

                  PrimaryButton(
                    label: _isLoading ? "Creating..." : "Create Password",
                    onTap: _isLoading ? () {} : _handleCreatePassword,
                  ),
                  SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}