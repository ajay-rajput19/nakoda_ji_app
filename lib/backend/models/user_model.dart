class UserModel {
  final String id;
  final String firstName;
  final String email;
  final String phone;
  final String password;

  UserModel({
    required this.id,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.password,
  });

  // Empty constructor for Riverpod
  UserModel.empty()
      : id = '',
        firstName = '',
        email = '',
        phone = '',
        password = '';

  // From JSON factory
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    String? firstName,
    String? email,
    String? phone,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
    );
  }

  // toString (secure – hides password)
  @override
  String toString() {
    return 'UserModel(id: $id, firstName: $firstName, email: $email, phone: $phone)';
  }

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.firstName == firstName &&
        other.email == email &&
        other.phone == phone &&
        other.password == password;
  }

  // Hashcode
  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        password.hashCode;
  }
}