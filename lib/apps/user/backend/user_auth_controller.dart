import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nakoda_ji/backend/models/user_model.dart';
import 'package:nakoda_ji/backend/models/backend_response.dart';
import 'package:nakoda_ji/backend/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAuthController {
  static Future<String> handleRegister(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse(Urls.userRegister),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        BackendResponse res = BackendResponse.fromJson(
          json.decode(response.body),
        );

        if (res.isSuccess()) {
          if (res.data != null && res.data is Map<String, dynamic>) {
            final data = res.data;
            final token =
                data['token'] ??
                (data['user'] is Map ? data['user']['token'] : null) ??
                (data['auth'] is Map ? data['auth']['token'] : null);

            if (token != null && token is String) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('userAuthToken', token);
              return BackendResponse.successMsg;
            } else {
              return BackendResponse.successMsg;
            }
          } else {
            return BackendResponse.successMsg;
          }
        } else {
          if (res.message.contains('email') &&
              (res.message.contains('exist') ||
                  res.message.contains('already'))) {
            return 'Email already exists. Please use a different email.';
          }
          return res.errorDetail('Failed to register! Please try again');
        }
      } else {
        if (response.statusCode == 409) {
          return 'Email already exists. Please use a different email.';
        }
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  static Future<Map<String, dynamic>> handleLogin(
    String email,
    String password,
  ) async {
    try {
      if (email.isEmpty) {
        return {'success': false, 'message': 'Email is required'};
      }

      if (password.isEmpty) {
        return {'success': false, 'message': 'Password is required'};
      }

      final response = await http.post(
        Uri.parse(Urls.userLogin),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        BackendResponse res = BackendResponse.fromJson(
          json.decode(response.body),
        );

        if (res.isSuccess()) {
          String? role;
          String? token;
          bool hasApp = false;
          String? appId;

          if (res.data != null && res.data is Map<String, dynamic>) {
            final data = res.data;

            token =
                data['token'] ??
                (data['user'] is Map ? data['user']['token'] : null) ??
                (data['auth'] is Map ? data['auth']['token'] : null);

            if (data['user'] is Map) {
              final user = data['user'];
              
              // Extract roles
              if (user['roles'] is List && user['roles'].isNotEmpty) {
                role = user['roles'][0];
              } else if (user['role'] is String) {
                role = user['role'];
              }

              // Extract and save membership flags
              hasApp = user['hasMembershipApplication'] ?? false;
              appId = user['membershipApplicationId']?.toString();

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('hasMembershipApplication', hasApp);
              if (appId != null) {
                await prefs.setString('memberRegistrationApplicationId', appId);
              }
              
              print('📍 [UserAuthController] Role: $role');
              print('📍 [UserAuthController] Has Application: $hasApp');
              print('📍 [UserAuthController] Application ID: $appId');
            }

            if (token != null) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              print('token: $token');
              await prefs.setString('userAuthToken', token);
              if (role != null) {
                await prefs.setString('userRole', role);
              }
            }
          }

          return {
            'success': true,
            'message': 'success',
            'role': role ?? 'user',
            'hasMembershipApplication': hasApp,
            'membershipApplicationId': appId,
          };
        } else {
          return {
            'success': false,
            'message': res.errorDetail(
              'Invalid credentials. Please try again.',
            ),
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Invalid email or password. Please try again.',
        };
      } else {
        return {'success': false, 'message': 'Login failed. Please try again.'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred during login. Please try again.',
      };
    }
  }

  static Future<String> handleOtpVerify(String email, String otp) async {
    try {
      if (otp.isEmpty) {
        return 'OTP is required';
      }

      if (email.isEmpty) {
        return 'Email is required';
      }

      final response = await http.post(
        Uri.parse(Urls.userVerifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        BackendResponse res = BackendResponse.fromJson(
          json.decode(response.body),
        );

        if (res.isSuccess()) {
          return BackendResponse.successMsg;
        } else {
          return res.errorDetail('Invalid OTP. Please try again.');
        }
      } else if (response.statusCode == 400) {
        try {
          final errorResponse = json.decode(response.body);
          if (errorResponse['message'] != null) {
            return errorResponse['message'];
          }
        } catch (e) {}
        return 'Invalid OTP. Please try again.';
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  static Future<String> handleResendOtp(String email) async {
    try {
      if (email.isEmpty) {
        return 'Email is required';
      }

      final response = await http.post(
        Uri.parse(Urls.userResendOtp),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        BackendResponse res = BackendResponse.fromJson(
          json.decode(response.body),
        );

        if (res.isSuccess()) {
          return 'OTP resent successfully. Please check your email.';
        } else {
          return res.errorDetail('Failed to resend OTP. Please try again.');
        }
      } else if (response.statusCode == 400) {
        try {
          final errorResponse = json.decode(response.body);
          if (errorResponse['message'] != null) {
            return errorResponse['message'];
          }
        } catch (e) {}
        return 'Failed to resend OTP. Please try again.';
      }
      return 'error';
    } catch (e) {
      return 'error';
    }
  }

  static Future<String> handleForgotPassword(String email) async {
    try {
      if (email.isEmpty) {
        return 'Email is required';
      }

      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        return 'Please enter a valid email address';
      }

      final response = await http.post(
        Uri.parse(Urls.userForgotPassword),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        BackendResponse res = BackendResponse.fromJson(
          json.decode(response.body),
        );

        if (res.isSuccess()) {
          return 'success';
        } else {
          return res.errorDetail(
            'Failed to process forgot password request. Please try again.',
          );
        }
      } else if (response.statusCode == 404) {
        return 'No account found with this email address';
      } else {
        return 'Failed to process forgot password request. Please try again.';
      }
    } catch (e) {
      return 'An error occurred while processing your request. Please try again.';
    }
  }

  static Future<String> handleForgotPasswordOtpVerify(
    String email,
    String otp,
  ) async {
    try {
      if (otp.isEmpty) {
        return 'OTP is required';
      }

      if (email.isEmpty) {
        return 'Email is required';
      }

      final response = await http.post(
        Uri.parse(Urls.userForgotPasswordVerifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        BackendResponse res = BackendResponse.fromJson(
          json.decode(response.body),
        );

        if (res.isSuccess()) {
          return BackendResponse.successMsg;
        } else {
          return res.errorDetail('Invalid OTP. Please try again.');
        }
      } else if (response.statusCode == 400) {
        try {
          final errorResponse = json.decode(response.body);
          if (errorResponse['message'] != null) {
            return errorResponse['message'];
          }
        } catch (e) {}
        return 'Invalid OTP. Please try again.';
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  static Future<String> handleCreatePassword(
    String token,
    String password,
  ) async {
    try {
      if (token.isEmpty) {
        return 'Reset token is required';
      }

      if (password.isEmpty) {
        return 'Password is required';
      }

      if (password.length < 8) {
        return 'Password must be at least 8 characters long';
      }

      if (!password.contains(RegExp(r'[A-Z]'))) {
        return 'Password must contain at least one uppercase letter';
      }

      if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return 'Password must contain at least one special character';
      }

      final response = await http.post(
        Uri.parse(Urls.userCreatePassword),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        BackendResponse res = BackendResponse.fromJson(
          json.decode(response.body),
        );

        if (res.isSuccess()) {
          return 'success';
        } else {
          return res.errorDetail(
            'Failed to create password. Please try again.',
          );
        }
      } else if (response.statusCode == 400) {
        try {
          final errorResponse = json.decode(response.body);
          if (errorResponse['message'] != null) {
            return errorResponse['message'];
          }
        } catch (e) {}
        return 'Failed to create password. Please try again.';
      } else if (response.statusCode == 404) {
        return 'Invalid reset token';
      } else {
        return 'Failed to create password. Please try again.';
      }
    } catch (e) {
      return 'An error occurred while processing your request. Please try again.';
    }
  }
}
