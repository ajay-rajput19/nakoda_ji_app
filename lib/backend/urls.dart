class Urls {
  static String get baseUrl {
    return 'https://p7fl63s4-5000.inc1.devtunnels.ms/api';
  }

  static String userRegister = '$baseUrl/auth/register'; //Post
  static String userVerifyOtp = '$baseUrl/auth/verify-email'; //Post
  static String userResendOtp = '$baseUrl/auth/resend-otp'; //Post
  static String userLogin = '$baseUrl/auth/login'; //Post
  static String userForgotPassword = '$baseUrl/auth/forgot-password'; //Post
  static String userForgotPasswordVerifyOtp = '$baseUrl/auth/verify-otp'; //Post
  static String userCreatePassword = '$baseUrl/auth/reset-password'; //Post
}
