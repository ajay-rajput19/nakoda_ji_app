import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nakoda_ji/apps/user/backend/user_auth_controller.dart';
import 'package:nakoda_ji/apps/user/screens/auth/password_create.dart';
import 'package:nakoda_ji/apps/user/screens/auth/user_Login.dart';
import 'package:nakoda_ji/apps/user/screens/components/AuthTopWidget.dart';
import 'package:nakoda_ji/components/buttons/primary_btn.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';
import 'package:nakoda_ji/utils/snackbar_helper.dart';
import 'dart:async';

class OtpVerify extends ConsumerStatefulWidget {
  final String email;
  final bool isForgotPassword;

  const OtpVerify({
    super.key,
    required this.email,
    this.isForgotPassword = false,
  });

  @override
  ConsumerState<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends ConsumerState<OtpVerify> {
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  bool _isVerifying = false;
  bool _isResending = false;
  bool _isResendDisabled = false;
  int _resendTimer = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Timer will start only when user clicks Resend OTP
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _isResendDisabled = true;
      _resendTimer = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _resendTimer--;
      });

      if (_resendTimer <= 0) {
        _timer?.cancel();
        setState(() {
          _isResendDisabled = false;
        });
      }
    });
  }

  Future<void> _handleOtpVerification() async {
    String otp = '';
    for (var controller in _controllers) {
      otp += controller.text;
    }

    if (otp.length != 4) {
      _showError('Please enter a valid 4-digit OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      String result;
      if (widget.isForgotPassword) {
        result = await UserAuthController.handleForgotPasswordOtpVerify(
          widget.email,
          otp,
        );
      } else {
        result = await UserAuthController.handleOtpVerify(widget.email, otp);
      }

      setState(() {
        _isVerifying = false;
      });

      if (result == 'success') {
        _showSuccess('OTP verified successfully!');

        if (widget.isForgotPassword) {
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              AppNavigation(context).push(PasswordCreate(token: otp));
            }
          });
        } else {
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              AppNavigation(context).push(UserLogin());
            }
          });
        }
      } else {
        _showError(result);
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });
      _showError('An error occurred during OTP verification');
    }
  }

  Future<void> _handleResendOtp() async {
    if (_isResendDisabled) return;

    setState(() {
      _isResending = true;
    });

    try {
      final result = await UserAuthController.handleResendOtp(widget.email);

      setState(() {
        _isResending = false;
      });

      if (result.contains('successfully')) {
        _showSuccess(result);
        _startResendTimer();
      } else {
        _showError(result);
      }
    } catch (e) {
      setState(() {
        _isResending = false;
      });
      _showError('An error occurred while resending OTP');
    }
  }

  void _showError(String message) {
    SnackbarHelper.show(context, message: message, backgroundColor: Colors.red);
  }

  void _showSuccess(String message) {
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
                  AuthTopWidget(
                    title: widget.isForgotPassword
                        ? "Reset Password OTP"
                        : "OTP Verification",
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) => _buildOtpBox(index)),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _isResendDisabled || _isResending
                          ? null
                          : () => _handleResendOtp(),
                      child: Text(
                        _isResendDisabled
                            ? "Resend in $_resendTimer s"
                            : _isResending
                            ? "Resending..."
                            : "Resend OTP",
                        style: TextStyle(
                          color: _isResendDisabled || _isResending
                              ? Colors.grey
                              : CustomColors.clrBtnBg,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: "Verify OTP",
                    isLoading: _isVerifying,
                    onTap: _isVerifying
                        ? () {}
                        : () => _handleOtpVerification(),
                  ),
                  SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                      children: [
                        TextSpan(
                          text: widget.isForgotPassword
                              ? "Enter the OTP sent to "
                              : "Enter the OTP sent to ",
                        ),
                        TextSpan(
                          text: widget.email,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: CustomColors.clrBtnBg,
                          ),
                        ),
                        TextSpan(
                          text: widget.isForgotPassword
                              ? " to reset your password."
                              : " to verify your account.",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CustomColors.clrborder, width: 1),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: CustomColors.clrBlack,
          ),
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else {
                _focusNodes[index].unfocus();
              }
            } else {
              if (index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            }
          },
        ),
      ),
    );
  }
}
