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
      id: json['id'] ?? '',
      applicantName: json['applicantName'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
      aadhaarNumber: json['aadhaarNumber'] ?? '',
      familyId: json['familyId'] ?? '',
      constituency: json['constituency'] ?? '',
      status: json['status'] ?? 'Draft',
      submittedAt: json['submittedAt'] ?? '',
      gender: json['gender'],
      dob: json['dob'],
      phone: json['phone'],
      address: json['address'],
      areaId: json['areaId'],
      yearsInPermanentAddress: json['yearsInPermanentAddress'],
      currentAddress: json['currentAddress'],
      permanentAddress: json['permanentAddress'],
      fathersName: json['fathersName'],
      mode: json['mode'],
      applicantUserId: json['applicantUserId'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      documents: json['documents'] != null ? List<dynamic>.from(json['documents']) : null,
      fieldReviews: json['fieldReviews'] != null ? List<dynamic>.from(json['fieldReviews']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    // Only add fields that are allowed/expected for creation/update
    
    data['email'] = email;
    data['aadhaarNumber'] = aadhaarNumber;
    
    // familyId was "not allowed".
    // data['familyId'] = familyId; 
    
    // constituency was "not allowed"
    // data['constituency'] = constituency;
    
    // "mode" must be one of [ONLINE, OFFLINE]
    if (mode != null) data['mode'] = mode;
    
    if (gender != null) data['gender'] = gender;
    
    // dob was "not allowed".
    // if (dob != null) data['dob'] = dob;
    
    // phone was "not allowed".
    // if (phone != null) data['phone'] = phone;
    
    // address was "not allowed", currentAddress "must be a string".
    if (currentAddress != null) data['currentAddress'] = currentAddress;
    // If we have address but no currentAddress, use address as currentAddress
    else if (address != null) data['currentAddress'] = address;
    
    if (areaId != null) data['areaId'] = areaId;
    if (yearsInPermanentAddress != null) data['yearsInPermanentAddress'] = yearsInPermanentAddress;
    if (permanentAddress != null) data['permanentAddress'] = permanentAddress;
    if (fathersName != null) data['fathersName'] = fathersName;
    
    // applicantUserId is probably allowed as it wasn't mentioned
    if (applicantUserId != null) data['applicantUserId'] = applicantUserId;

    return data;
  }
}
