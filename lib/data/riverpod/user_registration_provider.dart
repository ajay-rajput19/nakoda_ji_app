// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nakoda_ji/backend/models/user_model.dart';

// // Provider for user registration form state
// class UserRegistrationState {
//   final String firstName;
//   final String lastName;
//   final String email;
//   final String phone;
//   final String aadharNumber;
//   final String janAadhaar;
//   final String dateOfBirth;
//   final String gender;
//   final String address;
//   final String permanentAddress;
//   final bool isLoading;
//   final String errorMessage;

//   UserRegistrationState({
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.phone,
//     required this.aadharNumber,
//     required this.janAadhaar,
//     required this.dateOfBirth,
//     required this.gender,
//     required this.address,
//     required this.permanentAddress,
//     required this.isLoading,
//     required this.errorMessage,
//   });

//   // Initial state
//   factory UserRegistrationState.initial() {
//     return UserRegistrationState(
//       firstName: '',
//       lastName: '',
//       email: '',
//       phone: '',
//       aadharNumber: '',
//       janAadhaar: '',
//       dateOfBirth: '',
//       gender: '',
//       address: '',
//       permanentAddress: '',
//       isLoading: false,
//       errorMessage: '',
//     );
//   }

//   // Copy with method for updating state
//   UserRegistrationState copyWith({
//     String? firstName,
//     String? lastName,
//     String? email,
//     String? phone,
//     String? aadharNumber,
//     String? janAadhaar,
//     String? dateOfBirth,
//     String? gender,
//     String? address,
//     String? permanentAddress,
//     bool? isLoading,
//     String? errorMessage,
//   }) {
//     return UserRegistrationState(
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       email: email ?? this.email,
//       phone: phone ?? this.phone,
//       aadharNumber: aadharNumber ?? this.aadharNumber,
//       janAadhaar: janAadhaar ?? this.janAadhaar,
//       dateOfBirth: dateOfBirth ?? this.dateOfBirth,
//       gender: gender ?? this.gender,
//       address: address ?? this.address,
//       permanentAddress: permanentAddress ?? this.permanentAddress,
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }

//   // Convert to UserModel
//   UserModel toUserModel() {
//     return UserModel(
//       id: '', // Will be set by backend
//       firstName: firstName,
//       lastName: lastName,
//       email: email,
//       phone: phone,
//       aadharNumber: aadharNumber,
//       janAadhaar: janAadhaar,
//       dateOfBirth: dateOfBirth,
//       gender: gender,
//       address: address,
//       permanentAddress: permanentAddress,
//     );
//   }
// }

// // Riverpod provider for user registration
// class UserRegistrationNotifier extends Notifier<UserRegistrationState> {
//   @override
//   UserRegistrationState build() {
//     return UserRegistrationState.initial();
//   }

//   void updateFirstName(String firstName) {
//     state = state.copyWith(firstName: firstName);
//   }

//   void updateLastName(String lastName) {
//     state = state.copyWith(lastName: lastName);
//   }

//   void updateEmail(String email) {
//     state = state.copyWith(email: email);
//   }

//   void updatePhone(String phone) {
//     state = state.copyWith(phone: phone);
//   }

//   void updateAadharNumber(String aadharNumber) {
//     state = state.copyWith(aadharNumber: aadharNumber);
//   }

//   void updateJanAadhaar(String janAadhaar) {
//     state = state.copyWith(janAadhaar: janAadhaar);
//   }

//   void updateDateOfBirth(String dateOfBirth) {
//     state = state.copyWith(dateOfBirth: dateOfBirth);
//   }

//   void updateGender(String gender) {
//     state = state.copyWith(gender: gender);
//   }

//   void updateAddress(String address) {
//     state = state.copyWith(address: address);
//   }

//   void updatePermanentAddress(String permanentAddress) {
//     state = state.copyWith(permanentAddress: permanentAddress);
//   }

//   void setLoading(bool isLoading) {
//     state = state.copyWith(isLoading: isLoading);
//   }

//   void setError(String errorMessage) {
//     state = state.copyWith(errorMessage: errorMessage);
//   }

//   void clearError() {
//     state = state.copyWith(errorMessage: '');
//   }
// }

// final userRegistrationProvider = NotifierProvider<UserRegistrationNotifier, UserRegistrationState>(
//   UserRegistrationNotifier.new,
// );