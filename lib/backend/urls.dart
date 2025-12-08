class Urls {
  static String get baseUrl {
    return 'https://p7fl63s4-5001.inc1.devtunnels.ms/api';
  }

  static String userRegister = '$baseUrl/auth/register'; //Post
  static String userVerifyOtp = '$baseUrl/auth/verify-email'; //Post
  static String userResendOtp = '$baseUrl/auth/resend-otp'; //Post
  static String userLogin = '$baseUrl/auth/login'; //Post
  static String userForgotPassword = '$baseUrl/auth/forgot-password'; //Post
  static String userForgotPasswordVerifyOtp = '$baseUrl/auth/verify-otp'; //Post
  static String userCreatePassword = '$baseUrl/auth/reset-password'; //Post

  // Membership Endpoints
  static String membershipDraft =
      '$baseUrl/membership/applications/draft'; // POST
  static String membershipDocumentUpload =
      '$baseUrl/membership/applications/document/upload'; // POST
  static String membershipApplications =
      '$baseUrl/membership/applications'; // GET (list), POST (draft)
  static String membershipSubmit =
      '$baseUrl/membership/applications/submit'; // POST
  static String membershipReviewStart =
      '$baseUrl/membership/review/start'; // POST
  static String membershipReviewField =
      '$baseUrl/membership/review/field'; // POST
  static String membershipReviewDocument =
      '$baseUrl/membership/review/document'; // POST
  static String membershipReviewFinish =
      '$baseUrl/membership/review/finish'; // POST
  static String membershipPaymentOrder =
      '$baseUrl/membership/payments/order'; // POST
  static String membershipPaymentVerify =
      '$baseUrl/membership/payments/verify'; // POST
  static String membershipPaymentFailed =
      '$baseUrl/membership/payments/record-failed'; // POST
  static String membershipReviewUser = '$baseUrl/membership/review/user'; // GET
  static String membershipReview = '$baseUrl/membership/review'; // GET
  static String membershipUser = '$baseUrl/membership/user'; // GET
  static String activeAreas = '$baseUrl/areas/active'; // GET
}
