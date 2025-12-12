class MembershipModel {
  final String id;
  final String applicantName;
  final String email;
  final String? profileImage;
  final String aadhaarNumber;
  final String familyId;
  final String constituency;
  final String status;
  final String submittedAt;
  final String? gender;
  final String? dob;
  final String? phone;
  final String? address;
  final String? areaId;
  final int? yearsInPermanentAddress;
  final String? currentAddress;
  final String? permanentAddress;
  final String? fathersName;
  final String? mode;
  final String? applicantUserId;
  final String? updatedAt;
  final String? createdAt;
  final List<dynamic>? documents;
  final List<dynamic>? fieldReviews;

  MembershipModel({
    required this.id,
    required this.applicantName,
    required this.email,
    this.profileImage,
    required this.aadhaarNumber,
    required this.familyId,
    required this.constituency,
    required this.status,
    required this.submittedAt,
    this.gender,
    this.dob,
    this.phone,
    this.address,
    this.areaId,
    this.yearsInPermanentAddress,
    this.currentAddress,
    this.permanentAddress,
    this.fathersName,
    this.mode,
    this.applicantUserId,
    this.updatedAt,
    this.createdAt,
    this.documents,
    this.fieldReviews,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      id: json['id']?.toString() ?? '',
      
      applicantName: json['applicantName'] ??
          json['fullName'] ??
          json['name'] ??
          '',
      
      email: json['email'] ??
          json['emailId'] ??
          '',
      
      profileImage: json['profileImage'] ??
          json['photo'],
      
      aadhaarNumber: json['aadhaarNumber'] ??
          json['aadhar_no'] ??
          json['aadhar'] ??
          '',
      
      familyId: json['familyId'] ??
          json['janAadhaarFamilyId'] ??
          json['janAadharId'] ??
          '',
      
      constituency: json['constituency'] ??
          json['vidhansabha'] ??
          '',
      
      status: json['status'] ?? 'Draft',
      
      submittedAt: json['submittedAt'] ??
          json['createdAt'] ??
          '',
      
      gender: json['gender'],
      dob: json['dob'] ??
          json['dateOfBirth'],
      
      phone: json['phone'] ??
          json['phoneNumber'],
      
      address: json['address'],
      
      areaId: json['areaId'] ?? '',
      
      yearsInPermanentAddress: json['yearsInPermanentAddress'],
      
      currentAddress: json['currentAddress'] ??
          json['residentialAddress'],
      
      permanentAddress: json['permanentAddress'] ??
          json['homeAddress'],
      
      fathersName: json['fathersName'] ??
          json['fatherName'] ??
          json['father'] ??
          '',
      
      mode: json['mode'],
      
      applicantUserId: json['applicantUserId'],
      
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      
      documents: json['documents'] != null
          ? List<dynamic>.from(json['documents'])
          : null,
      
      fieldReviews: json['fieldReviews'] != null
          ? List<dynamic>.from(json['fieldReviews'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['applicantName'] = applicantName;
    data['email'] = email;
    if (profileImage != null) data['profileImage'] = profileImage;
    data['aadhaarNumber'] = aadhaarNumber;
    data['familyId'] = familyId;
    data['constituency'] = constituency;
    data['status'] = status;
    data['submittedAt'] = submittedAt;

    if (mode != null) data['mode'] = mode;
    if (gender != null) data['gender'] = gender;
    if (dob != null) data['dob'] = dob;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    
    if (currentAddress != null) data['currentAddress'] = currentAddress;
    
    if (areaId != null) data['areaId'] = areaId;
    if (yearsInPermanentAddress != null) {
      data['yearsInPermanentAddress'] = yearsInPermanentAddress;
    }
    if (permanentAddress != null) data['permanentAddress'] = permanentAddress;
    if (fathersName != null) data['fathersName'] = fathersName;
    
    if (applicantUserId != null) data['applicantUserId'] = applicantUserId;
    
    if (updatedAt != null) data['updatedAt'] = updatedAt;
    if (createdAt != null) data['createdAt'] = createdAt;
    
    if (documents != null) data['documents'] = documents;
    if (fieldReviews != null) data['fieldReviews'] = fieldReviews;

    return data;
  }
}
