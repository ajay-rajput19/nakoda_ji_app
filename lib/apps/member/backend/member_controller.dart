import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nakoda_ji/backend/models/backend_response.dart';
import 'package:nakoda_ji/backend/models/membership_model.dart';
import 'package:nakoda_ji/backend/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberController {
  static Future<Map<String, String>> _getHeaders({
    bool isMultipart = false,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userAuthToken');
    Map<String, String> headers = {
      if (!isMultipart) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    return headers;
  }

  // Helper method to extract MembershipModel from BackendResponse data
  static MembershipModel? _extractMembershipModel(dynamic data) {
    if (data == null) return null;

    try {
      if (data is Map<String, dynamic>) {
        return MembershipModel.fromJson(data);
      } else if (data is List && data.isNotEmpty) {
        return MembershipModel.fromJson(data[0]);
      }
    } catch (e) {
      print('Error extracting membership model: $e');
    }

    return null;
  }

  // ADD NEW DRAFT
  static Future<BackendResponse> addMembershipDraft(
    MembershipModel membership,
  ) async {
    try {
      print('\n🔵 [MEMBER CONTROLLER] addMembershipDraft called');

      final headers = await _getHeaders();
      final url = Uri.parse(Urls.membershipDraft);
      final body = json.encode(membership.toJson());

      print('📍 URL: $url');
      print('🔑 Headers: $headers');
      print('📦 Request Body: $body');

      final response = await http.post(url, headers: headers, body: body);

      print('📨 Response Status Code: ${response.statusCode}');
      _printLongLog('📨 Response Body: ${response.body}');

      final backendResponse = BackendResponse.fromJson(
        json.decode(response.body),
      );

      print('✅ Parsed Response - Success: ${backendResponse.isSuccess()}');
      print('📝 Parsed Response - Message: ${backendResponse.message}');
      print('🔵 [MEMBER CONTROLLER] addMembershipDraft finished\n');

      return backendResponse;
    } catch (e) {
      print('❌ [MEMBER CONTROLLER] Error in addMembershipDraft: $e\n');
      return BackendResponse(success: false, message: 'Error adding draft: $e');
    }
  }

  // UPLOAD DOCUMENTS
  static Future<BackendResponse> uploadMembershipDocuments({
    required String applicationId,
    required List<({String documentTypeId, File file})> documents,
  }) async {
    try {
      final headers = await _getHeaders(isMultipart: true);
      List<dynamic> results = [];

      for (var doc in documents) {
        print('📤 [MEMBER CONTROLLER] Uploading Document:');
        print('   - App ID: $applicationId');
        print('   - Doc Type ID: ${doc.documentTypeId}');
        print('   - File: ${doc.file.path}');

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(Urls.membershipDocumentUpload),
        );
        request.headers.addAll(headers);
        request.fields['applicationId'] = applicationId;
        request.fields['documentTypeId'] = doc.documentTypeId;

        var multipartFile = await http.MultipartFile.fromPath(
          'file',
          doc.file.path,
        );
        request.files.add(multipartFile);

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print('📨 [MEMBER CONTROLLER] Status: ${response.statusCode}');
        print('📨 [MEMBER CONTROLLER] Response: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          results.add(json.decode(response.body));
        } else {
          print('❌ [MEMBER CONTROLLER] Upload Failed');
          return BackendResponse(
            success: false,
            message: 'Error uploading document: ${response.statusCode}',
          );
        }
      }
      return BackendResponse(
        success: true,
        message: 'Documents processed',
        data: results,
      );
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error uploading documents: $e',
      );
    }
  }

  // GET BY ID
  static Future<BackendResponse> fetchMembershipById(String id) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${Urls.membershipApplications}/$id');
      print('\n🚀 [MEMBER CONTROLLER] fetchMembershipById');
      print('📍 URL: $url');

      final response = await http.get(url, headers: headers);

      print('📨 Status Code: ${response.statusCode}');
      _printLongLog('📨 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final res = BackendResponse.fromJson(json.decode(response.body));
        return res;
      }
      return BackendResponse(
        success: false,
        message: 'Error fetching membership: ${response.statusCode}',
        detail: response.body,
      );
    } catch (e) {
      print('❌ [MEMBER CONTROLLER] Error: $e');
      return BackendResponse(
        success: false,
        message: 'Error fetching membership: $e',
      );
    }
  }

  // GET BY ID AS MODEL
  static Future<MembershipModel?> fetchMembershipModelById(String id) async {
    try {
      final response = await fetchMembershipById(id);
      if (response.isSuccess() && response.data != null) {
        return _extractMembershipModel(response.data);
      }
    } catch (e) {
      print('Error fetching membership model: $e');
    }
    return null;
  }

  // GET MEMBERSHIP PROFILE
  static Future<BackendResponse> getMembershipProfile(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Urls.membershipUser}/$id'),
        headers: headers,
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error fetching profile: $e',
      );
    }
  }

  // GET MEMBERSHIP PROFILE AS MODEL
  static Future<MembershipModel?> getMembershipProfileModel(String id) async {
    try {
      final response = await getMembershipProfile(id);
      if (response.isSuccess() && response.data != null) {
        return _extractMembershipModel(response.data);
      }
    } catch (e) {
      print('Error getting membership profile model: $e');
    }
    return null;
  }

  // SUBMIT MEMBERSHIP APPLICATION
  static Future<BackendResponse> submitMembership(
    Map<String, dynamic> payload,
  ) async {
    try {
      final headers = await _getHeaders();
      print('📍 [MemberController] POST ${Urls.membershipSubmit}');
      print('📡 [MemberController] Payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse(Urls.membershipSubmit),
        headers: headers,
        body: json.encode(payload),
      );

      print('📦 [MemberController] Status: ${response.statusCode}');
      _printLongLog('📨 [MemberController] Response: ${response.body}');

      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      print('❌ [MemberController] Exception: $e');
      return BackendResponse(
        success: false,
        message: 'Error submitting application: $e',
      );
    }
  }

  // UPDATE
  static Future<BackendResponse> editMembership(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final headers = await _getHeaders();
      print(
        '📍 [MemberController] PATCH ${Urls.membershipApplications}/$id/draft',
      );
      print('📡 [MemberController] Payload: ${json.encode(payload)}');

      final response = await http.patch(
        Uri.parse('${Urls.membershipApplications}/$id/draft'),
        headers: headers,
        body: json.encode(payload),
      );

      print('📦 [MemberController] Status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        _printLongLog('⚠️ [MemberController] Error Body: ${response.body}');
      } else {
        _printLongLog('📨 [MemberController] Success Body: ${response.body}');
      }

      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      print('❌ [MemberController] Exception: $e');
      return BackendResponse(
        success: false,
        message: 'Error updating membership: $e',
      );
    }
  }

  // Helper to print long strings in chunks
  static void _printLongLog(String message) {
    const int chunkSize = 800;
    for (int i = 0; i < message.length; i += chunkSize) {
      int end = (i + chunkSize < message.length)
          ? i + chunkSize
          : message.length;
      print(message.substring(i, end));
    }
  }

  // DELETE
  static Future<BackendResponse> removeMembership(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${Urls.membershipApplications}/$id'), // Assuming consistency
        headers: headers,
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error deleting membership: $e',
      );
    }
  }

  // START REVIEW PROCESS
  static Future<BackendResponse> startMembershipReview(
    String applicationId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(Urls.membershipReviewStart),
        headers: headers,
        body: json.encode({'applicationId': applicationId}),
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error starting review: $e',
      );
    }
  }

  // REVIEW INDIVIDUAL FIELD
  static Future<BackendResponse> reviewMembershipField({
    required String applicationId,
    required String fieldName,
    required String status,
    String? remark,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(Urls.membershipReviewField),
        headers: headers,
        body: json.encode({
          'applicationId': applicationId,
          'fieldName': fieldName,
          'status': status,
          'remark': remark,
        }),
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error reviewing field: $e',
      );
    }
  }

  // REVIEW DOCUMENT
  static Future<BackendResponse> reviewMembershipDocument({
    required String membershipDocumentId,
    required String status,
    String? remark,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(Urls.membershipReviewDocument),
        headers: headers,
        body: json.encode({
          'membershipDocumentId': membershipDocumentId,
          'status': status,
          'remark': remark,
        }),
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error reviewing document: $e',
      );
    }
  }

  // GET REVIEW STATUS
  static Future<BackendResponse> getMembershipReviewStatus(
    String applicationId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Urls.membershipReview}/$applicationId'),
        headers: headers,
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error fetching review status: $e',
      );
    }
  }

  // FINISH REVIEW
  static Future<BackendResponse> finishMembershipReview({
    required String applicationId,
    required String decision,
    String? remark,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(Urls.membershipReviewFinish),
        headers: headers,
        body: json.encode({
          'applicationId': applicationId,
          'decision': decision,
          'remark': remark,
        }),
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error finishing review: $e',
      );
    }
  }

  // SAVE CORRECTIONS
  static Future<BackendResponse> saveMembershipCorrections(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${Urls.membershipApplications}/$id/corrections');
      
      print('\n🚀 [MEMBER CONTROLLER] saveMembershipCorrections');
      print('📍 URL: $url');
      print('📡 Payload: ${json.encode(payload)}');

      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      print('📦 Status Code: ${response.statusCode}');
      _printLongLog('📨 Response Body: ${response.body}');

      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      print('❌ Error in saveMembershipCorrections: $e');
      return BackendResponse(
        success: false,
        message: 'Error saving corrections: $e',
      );
    }
  }

  // PROCESS MEMBERSHIP APPLICATION (APPROVE/REJECT)
  static Future<BackendResponse> processMembershipApplication({
    required String id,
    required List<dynamic> fieldReviews,
    required String action, // approve or reject
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${Urls.membershipApplications}/$id/$action'),
        headers: headers,
        body: json.encode({'fieldReviews': fieldReviews}),
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error processing application: $e',
      );
    }
  }

  // CREATE PAYMENT ORDER
  static Future<BackendResponse> createPaymentOrder(
    String applicationId,
    double amount,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(Urls.membershipPaymentOrder),
        headers: headers,
        body: json.encode({
          'applicationId': applicationId,
          'amount': amount,
          'currency': 'INR',
        }),
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error creating payment order: $e',
      );
    }
  }

  // VERIFY PAYMENT
  static Future<BackendResponse> verifyPayment({
    required String paymentId,
    required String signature,
    required String orderId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(Urls.membershipPaymentVerify),
        headers: headers,
        body: json.encode({
          'paymentId': paymentId,
          'signature': signature,
          'orderId': orderId,
        }),
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error verifying payment: $e',
      );
    }
  }

  // RECORD FAILED PAYMENT
  static Future<BackendResponse> recordFailedPayment({
    required String applicationId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(Urls.membershipPaymentFailed),
        headers: headers,
        body: json.encode({
          'applicationId': applicationId,
          'paymentId': paymentId,
          'signature': signature,
        }),
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error recording failed payment: $e',
      );
    }
  }

  // GET REVIEW PROFILE FOR USER
  static Future<BackendResponse> getMembershipReviewProfile(
    String applicationId,
  ) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(Urls.membershipReviewUser(applicationId));
      print('\n🚀 [MEMBER CONTROLLER] getMembershipReviewProfile');
      print('📍 URL: $url');

      final response = await http.get(url, headers: headers);

      print('📨 Status Code: ${response.statusCode}');
      _printLongLog('📨 Response Body: ${response.body}');

      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      print('❌ [MEMBER CONTROLLER] Error: $e');
      return BackendResponse(
        success: false,
        message: 'Error fetching review profile: $e',
      );
    }
  }

  // FETCH ACTIVE AREAS
  static Future<BackendResponse> fetchActiveAreas() async {
    try {
      print('\n🔵 [MEMBER CONTROLLER] fetchActiveAreas called');
      final headers = await _getHeaders();
      final url = Uri.parse(Urls.activeAreas);
      print('📍 URL: $url');
      print('🔑 Headers: $headers');

      final response = await http.get(url, headers: headers);

      print('📨 Response Status Code: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');

      final backendResponse = BackendResponse.fromJson(
        json.decode(response.body),
      );
      print('✅ Parsed Response - Success: ${backendResponse.isSuccess()}');
      print('🔵 [MEMBER CONTROLLER] fetchActiveAreas finished\n');

      return backendResponse;
    } catch (e) {
      print('❌ [MEMBER CONTROLLER] Error in fetchActiveAreas: $e\n');
      return BackendResponse(
        success: false,
        message: 'Error fetching active areas: $e',
      );
    }
  }

  // FETCH DOCUMENT TYPES
  static Future<BackendResponse> fetchAllDocumentTypes() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(Urls.documentTypesUrl);

      final response = await http.get(url, headers: headers);

      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error fetching document types: $e',
      );
    }
  }

  // GET USER'S CURRENT MEMBERSHIP
  static Future<BackendResponse> fetchUserMembership() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(Urls.membershipUser);
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return BackendResponse.fromJson(json.decode(response.body));
      } else {
        return BackendResponse(
          success: false, 
          message: 'Error fetching user membership: ${response.body}'
        );
      }
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error fetching user membership: $e',
      );
    }
  }

  // --- BIOMETRIC ENDPOINTS ---

  // 1. Fetch Available Slots
  static Future<BackendResponse> fetchBiometricSlots({
    int page = 1,
    int limit = 10,
    String filter = 'upcoming',
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${Urls.biometricSlots}?page=$page&limit=$limit&filter=$filter');
      print('🔍 [MemberController] GET $url');
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return BackendResponse.fromJson(json.decode(response.body));
      } else {
         return BackendResponse(
          success: false, 
          message: 'Error fetching slots: ${response.body}'
        );
      }
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error fetching slots: $e',
      );
    }
  }

  // 2. Book Slot
  static Future<BackendResponse> bookBiometricSlot({
    required String scheduleId,
    required int slotNumber,
    required String membershipApplicationId,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(Urls.biometricBook);
      final body = json.encode({
        'scheduleId': scheduleId,
        'slotNumber': slotNumber,
        'membershipApplicationId': membershipApplicationId,
      });
      
      print('--------------------------------------------------');
      print('🚀 [BOOKING REQUEST START]');
      print('🔗 URL: $url');
      print('📦 Payload: $body');
      print('--------------------------------------------------');

      final response = await http.post(url, headers: headers, body: body);

      print('--------------------------------------------------');
      print('📩 [BOOKING RESPONSE]');
      print('✅ Status Code: ${response.statusCode}');
      print('� Response Body: ${response.body}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ API Error: ${response.reasonPhrase}');
      }
      print('--------------------------------------------------');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BackendResponse.fromJson(json.decode(response.body));
      } else {
        print('❌ [MemberController] Booking Error: ${response.body}');
        return BackendResponse(
          success: false,
          message: 'Booking failed: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ [MemberController] Exception: $e');
      return BackendResponse(
        success: false,
        message: 'Error booking slot: $e',
      );
    }
  }

  // 3. Fetch Member Bookings
  static Future<BackendResponse> fetchMemberBookings(String appId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(Urls.biometricMemberBookings(appId));
      print('🔍 [MemberController] GET $url');
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return BackendResponse.fromJson(json.decode(response.body));
      } else {
        return BackendResponse(
          success: false, 
          message: 'Error fetching bookings: ${response.body}'
        );
      }
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error fetching bookings: $e',
      );
    }
  }

  // 4. Cancel Booking
  static Future<BackendResponse> cancelBiometricBooking(String bookingId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(Urls.biometricCancelBooking(bookingId));
      print('🗑️ [MemberController] DELETE $url');
      
      final response = await http.delete(url, headers: headers);
      
      if (response.statusCode == 200) {
        return BackendResponse.fromJson(json.decode(response.body));
      } else {
        return BackendResponse(
          success: false, 
          message: 'Error cancelling booking: ${response.body}'
        );
      }
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error cancelling booking: $e',
      );
    }
  }
}
