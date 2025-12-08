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

  // ADD NEW DRAFT
  static Future<BackendResponse> addMembershipDraft(
    MembershipModel membership,
  ) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(Urls.membershipDraft);
      final body = json.encode(membership.toJson());

      final response = await http.post(url, headers: headers, body: body);

      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
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

        if (response.statusCode == 200 || response.statusCode == 201) {
          results.add(json.decode(response.body));
        } else {}
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
      final response = await http.get(
        Uri.parse('${Urls.membershipApplications}/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final res = BackendResponse.fromJson(json.decode(response.body));
        if (res.isSuccess() && res.data != null) {
          // If the API returns the object directly in data, we can try to parse it
          // Or let the caller handle the data parsing
          return res;
        }
        return res;
      }
      return BackendResponse(
        success: false,
        message: 'Error fetching membership',
      );
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error fetching membership: $e',
      );
    }
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

  // SUBMIT MEMBERSHIP APPLICATION
  static Future<BackendResponse> submitMembership(
    Map<String, dynamic> payload,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(Urls.membershipSubmit),
        headers: headers,
        body: json.encode(payload),
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
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
      final response = await http.patch(
        Uri.parse('${Urls.membershipApplications}/$id/draft'),
        headers: headers,
        body: json.encode(payload),
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error updating membership: $e',
      );
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
      final response = await http.patch(
        Uri.parse('${Urls.membershipApplications}/$id/corrections'),
        headers: headers,
        body: json.encode(payload),
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
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

  // GET REVIEW PROFILE
  static Future<BackendResponse> getMembershipReviewProfile(
    String applicationId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Urls.membershipReviewUser}/$applicationId'),
        headers: headers,
      );
      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error GET review profile: $e',
      );
    }
  }

  // FETCH ACTIVE AREAS
  static Future<BackendResponse> fetchActiveAreas() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(Urls.activeAreas);

      final response = await http.get(url, headers: headers);

      return BackendResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return BackendResponse(
        success: false,
        message: 'Error fetching active areas: $e',
      );
    }
  }
}
