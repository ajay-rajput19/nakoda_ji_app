class MembershipModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String applicantName; // This maps to fullName
  final String email;
  final String? profileImage;
  final String aadhaarNumber;
  final String familyId; // This maps to janAadhaarFamilyId
  final String? constituency;
  final String status;
  final String submittedAt;
  final String? gender;
  final String? dob; // This maps to dateOfBirth
  final String? phone; // This maps to mobileNumber
  final String? phoneCode;
  final String? address;
  final AreaModel? area;
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

  // Specific address parts from documentation
  final String? permanentAddressLine1;
  final String? permanentAddressLine2;
  final String? permanentCity;
  final String? permanentState;
  final String? permanentZipCode;
  final String? permanentCountry;

  final String? currentAddressLine1;
  final String? currentAddressLine2;
  final String? currentCity;
  final String? currentState;
  final String? currentZipCode;
  final String? currentCountry;

  MembershipModel({
    required this.id,
    this.firstName,
    this.lastName,
    required this.applicantName,
    required this.email,
    this.profileImage,
    required this.aadhaarNumber,
    required this.familyId,
    this.constituency,
    required this.status,
    required this.submittedAt,
    this.gender,
    this.dob,
    this.phone,
    this.phoneCode,
    this.address,
    this.area,
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
    this.permanentAddressLine1,
    this.permanentAddressLine2,
    this.permanentCity,
    this.permanentState,
    this.permanentZipCode,
    this.permanentCountry,
    this.currentAddressLine1,
    this.currentAddressLine2,
    this.currentCity,
    this.currentState,
    this.currentZipCode,
    this.currentCountry,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    // Robust phone and code extraction
    String? extractedPhone;
    String? extractedCode = '+91';

    // Check various common keys and types
    dynamic phoneData =
        json['phone'] ?? json['mobileNumber'] ?? json['phoneNumber'];

    if (phoneData is Map) {
      extractedPhone = phoneData['number']?.toString();
      extractedCode = phoneData['code']?.toString() ?? '+91';

      // FALLBACK: if map has no number, look at top level mobileNumber
      if (extractedPhone == null || extractedPhone.isEmpty) {
        extractedPhone = (json['mobileNumber'] ?? json['phoneNumber'])
            ?.toString();
      }
    } else {
      extractedPhone = phoneData?.toString();
      extractedCode = json['phoneCode']?.toString() ?? '+91';
    }

    // Construct Address strings if they are individual fields
    String? pAddr = json['permanentAddress'] ?? json['homeAddress'];
    if (pAddr == null && json['permanentAddressLine1'] != null) {
      pAddr = [
        json['permanentAddressLine1'],
        json['permanentAddressLine2'],
        json['permanentCity'],
        json['permanentState'],
        json['permanentZipCode'],
        json['permanentCountry'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
    }

    String? cAddr = json['currentAddress'] ?? json['residentialAddress'];
    if (cAddr == null && json['currentAddressLine1'] != null) {
      cAddr = [
        json['currentAddressLine1'],
        json['currentAddressLine2'],
        json['currentCity'],
        json['currentState'],
        json['currentZipCode'],
        json['currentCountry'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
    }

    return MembershipModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      applicantName:
          json['fullName'] ??
          json['applicantName'] ??
          json['name'] ??
          ((json['firstName'] != null || json['lastName'] != null)
              ? '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim()
              : ''),
      email: json['email'] ?? json['emailId'] ?? '',
      profileImage: json['profileImage'] ?? json['photo'],
      aadhaarNumber:
          json['aadhaarNumber'] ?? json['aadhar_no'] ?? json['aadhar'] ?? '',
      familyId:
          json['janAadhaarFamilyId'] ??
          json['familyId'] ??
          json['janAadharId'] ??
          '',
      constituency: (json['constituency'] is Map)
          ? json['constituency']['name']?.toString() ??
                json['constituency']['title']?.toString()
          : (json['constituency'] ?? json['vidhansabha'] ?? '').toString(),
      status: json['status'] ?? 'Draft',
      submittedAt: json['submittedAt'] ?? json['createdAt'] ?? '',
      gender: json['gender'],
      dob: (json['dateOfBirth'] ?? json['dob'] ?? '').toString().split('T')[0],
      phone: extractedPhone,
      phoneCode: extractedCode,
      address: json['address'],
      area: (json['area'] is Map)
          ? AreaModel.fromJson(json['area'])
          : (json['areaId'] is Map)
          ? AreaModel.fromJson(json['areaId'])
          : null,
      yearsInPermanentAddress: json['yearsInPermanentAddress'],
      currentAddress: cAddr,
      permanentAddress: pAddr,
      fathersName:
          json['fathersName'] ?? json['fatherName'] ?? json['father'] ?? '',
      mode: json['mode'] ?? 'ONLINE',
      applicantUserId: json['applicantUserId'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      documents: json['documents'] != null
          ? List<dynamic>.from(json['documents'])
          : null,
      fieldReviews: json['fieldReviews'] != null
          ? List<dynamic>.from(json['fieldReviews'])
          : null,
      permanentAddressLine1: json['permanentAddressLine1'],
      permanentAddressLine2: json['permanentAddressLine2'],
      permanentCity: json['permanentCity'],
      permanentState: json['permanentState'],
      permanentZipCode: json['permanentZipCode'],
      permanentCountry: json['permanentCountry'],
      currentAddressLine1: json['currentAddressLine1'],
      currentAddressLine2: json['currentAddressLine2'],
      currentCity: json['currentCity'],
      currentState: json['currentState'],
      currentZipCode: json['currentZipCode'],
      currentCountry: json['currentCountry'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id.isNotEmpty) data['id'] = id;
    if (firstName != null && firstName!.isNotEmpty)
      data['firstName'] = firstName;
    if (lastName != null && lastName!.isNotEmpty) data['lastName'] = lastName;

    if (applicantName.isNotEmpty) {
      data['fullName'] = applicantName;
      data['applicantName'] = applicantName;
    }

    if (email.isNotEmpty) data['email'] = email;
    if (profileImage != null && profileImage!.isNotEmpty) {
      data['profileImage'] = profileImage;
    }

    if (aadhaarNumber.isNotEmpty) data['aadhaarNumber'] = aadhaarNumber;

    if (familyId.isNotEmpty) {
      data['janAadhaarFamilyId'] = familyId;
      data['familyId'] = familyId;
    }

    if (constituency != null && constituency!.isNotEmpty) {
      data['constituency'] = constituency;
    }

    if (status.isNotEmpty) data['status'] = status;
    if (submittedAt.isNotEmpty) data['submittedAt'] = submittedAt;

    data['mode'] = mode ?? 'ONLINE';
    if (gender != null && gender!.isNotEmpty) data['gender'] = gender;

    if (dob != null && dob!.isNotEmpty) {
      data['dateOfBirth'] = dob;
      data['dob'] = dob;
    }

    if (phone != null && phone!.isNotEmpty) {
      data['mobileNumber'] = phone;
      data['phone'] = phone;
      data['phoneNumber'] = phone;
    }

    data['phoneCode'] = phoneCode ?? '+91';

    if (address != null && address!.isNotEmpty) data['address'] = address;
    if (currentAddress != null && currentAddress!.isNotEmpty) {
      data['currentAddress'] = currentAddress;
    }

    if (area != null) {
      data['area'] = area!.toJson();
    }

    if (yearsInPermanentAddress != null) {
      data['yearsInPermanentAddress'] = yearsInPermanentAddress;
    }

    if (permanentAddress != null && permanentAddress!.isNotEmpty) {
      data['permanentAddress'] = permanentAddress;
    }

    if (fathersName != null && fathersName!.isNotEmpty) {
      data['fathersName'] = fathersName;

      if (applicantUserId != null && applicantUserId!.isNotEmpty) {
        data['applicantUserId'] = applicantUserId;
      }

      // Specific address parts
      if (permanentAddressLine1 != null && permanentAddressLine1!.isNotEmpty) {
        data['permanentAddressLine1'] = permanentAddressLine1;
      }
      if (permanentAddressLine2 != null && permanentAddressLine2!.isNotEmpty) {
        data['permanentAddressLine2'] = permanentAddressLine2;
      }
      if (permanentCity != null && permanentCity!.isNotEmpty) {
        data['permanentCity'] = permanentCity;
      }
    }
    if (permanentState != null && permanentState!.isNotEmpty) {
      data['permanentState'] = permanentState;
    }
    if (permanentZipCode != null && permanentZipCode!.isNotEmpty) {
      data['permanentZipCode'] = permanentZipCode;
    }
    if (permanentCountry != null && permanentCountry!.isNotEmpty) {
      data['permanentCountry'] = permanentCountry;
    }

    if (currentAddressLine1 != null && currentAddressLine1!.isNotEmpty) {
      data['currentAddressLine1'] = currentAddressLine1;
    }
    if (currentAddressLine2 != null && currentAddressLine2!.isNotEmpty) {
      data['currentAddressLine2'] = currentAddressLine2;
    }
    if (currentCity != null && currentCity!.isNotEmpty) {
      data['currentCity'] = currentCity;
    }
    if (currentState != null && currentState!.isNotEmpty) {
      data['currentState'] = currentState;
    }
    if (currentZipCode != null && currentZipCode!.isNotEmpty) {
      data['currentZipCode'] = currentZipCode;
    }
    if (currentCountry != null && currentCountry!.isNotEmpty) {
      data['currentCountry'] = currentCountry;
    }

    return data;
  }
}

class AreaModel {
  final String id;
  final String name;
  final String? code;

  AreaModel({required this.id, required this.name, this.code});

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, if (code != null) 'code': code};
  }
}
