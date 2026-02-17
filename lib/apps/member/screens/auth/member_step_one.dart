import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nakoda_ji/components/buttons/button_with_icon.dart';
import 'package:nakoda_ji/components/inputs/date_input.dart';
import 'package:nakoda_ji/components/inputs/primary_input.dart';
import 'package:nakoda_ji/components/inputs/single_slecect_input.dart';
import 'package:nakoda_ji/apps/member/backend/member_controller.dart';
import 'package:nakoda_ji/backend/models/membership_model.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/utils/snackbar_helper.dart';
import 'package:nakoda_ji/utils/localStorage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Custom Aadhar Card Input Formatter
class AadharInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');

    if (text.length > 12) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 3 || i == 7) && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class MemberStepOne extends StatefulWidget {
  final Function(String id)? onStepComplete;
  final String? applicationId;

  const MemberStepOne({super.key, this.onStepComplete, this.applicationId});

  @override
  State<MemberStepOne> createState() => _MemberStepOneState();
}

class _MemberStepOneState extends State<MemberStepOne> {
  // Basic Information Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _janAadhaarController = TextEditingController();

  // Permanent Address Controllers
  final TextEditingController _permanentAddressLine1Controller =
      TextEditingController();
  final TextEditingController _permanentAddressLine2Controller =
      TextEditingController();
  final TextEditingController _permanentCityController =
      TextEditingController();
  final TextEditingController _permanentStateController =
      TextEditingController();
  final TextEditingController _permanentZipCodeController =
      TextEditingController();
  final TextEditingController _permanentCountryController =
      TextEditingController();

  // Current Address Controllers
  final TextEditingController _currentAddressLine1Controller =
      TextEditingController();
  final TextEditingController _currentAddressLine2Controller =
      TextEditingController();
  final TextEditingController _currentCityController = TextEditingController();
  final TextEditingController _currentStateController = TextEditingController();
  final TextEditingController _currentZipCodeController =
      TextEditingController();
  final TextEditingController _currentCountryController =
      TextEditingController();

  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _numberOfYearsController =
      TextEditingController();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  List<dynamic> _activeAreas = [];
  String? _selectedAreaId;
  bool _sameAsPermanent = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchActiveAreas();
    _loadUserData(); // Load user data from registration
    _dateOfBirthController.addListener(_handleDobChange);
    if (widget.applicationId != null && widget.applicationId!.isNotEmpty) {
      _fetchApplicationData();
    }
  }

  Future<void> _fetchApplicationData() async {
    setState(() => _isLoading = true);
    final response = await MemberController.fetchMembershipById(
      widget.applicationId!,
    );
    if (response.isSuccess() && response.data != null) {
      final model = MembershipModel.fromJson(response.data);
      if (mounted) {
        setState(() {
          _firstNameController.text = model.firstName ?? '';
          _lastNameController.text = model.lastName ?? '';
          _emailController.text = model.email;
          _phoneController.text = model.phone ?? '';
          _dateOfBirthController.text = model.dob ?? '';
          _genderController.text = model.gender ?? '';
          _aadharController.text = _formatAadharData(model.aadhaarNumber);
          _fatherNameController.text = model.fathersName ?? '';
          _janAadhaarController.text = model.familyId;
          _selectedAreaId = model.area?.id;
          _numberOfYearsController.text =
              model.yearsInPermanentAddress?.toString() ?? '';
          _permanentAddressLine1Controller.text =
              model.permanentAddressLine1 ?? '';
          _permanentAddressLine2Controller.text =
              model.permanentAddressLine2 ?? '';
          _permanentCityController.text = model.permanentCity ?? '';
          _permanentStateController.text = model.permanentState ?? '';
          _permanentZipCodeController.text = model.permanentZipCode ?? '';
          _permanentCountryController.text = model.permanentCountry ?? 'India';

          // POPULATE CURRENT ADDRESS FIELDS
          _currentAddressLine1Controller.text = model.currentAddressLine1 ?? '';
          _currentAddressLine2Controller.text = model.currentAddressLine2 ?? '';
          _currentCityController.text = model.currentCity ?? '';
          _currentStateController.text = model.currentState ?? '';
          _currentZipCodeController.text = model.currentZipCode ?? '';
          _currentCountryController.text = model.currentCountry ?? 'India';

          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Load user data from SharedPreferences and pre-fill fields
  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Get user data from SharedPreferences
      String? firstName = prefs.getString(LocalStorage.userFirstName);
      String? lastName = prefs.getString(LocalStorage.userLastName);
      String? email = prefs.getString(LocalStorage.userEmail);
      String? phone = prefs.getString(LocalStorage.userPhone);

      // Pre-fill the fields if data exists
      if (firstName != null && firstName.isNotEmpty) {
        _firstNameController.text = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        _lastNameController.text = lastName;
      }
      if (email != null && email.isNotEmpty) {
        _emailController.text = email;
      }
      if (phone != null && phone.isNotEmpty) {
        _phoneController.text = phone;
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      // Try ISO format first (yyyy-MM-dd)
      return DateTime.parse(dateStr);
    } catch (e) {
      // Try DD/MM/YYYY format
      try {
        List<String> parts = dateStr.split('/');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } catch (e2) {
        // Fallback
      }
    }
    return null;
  }

  void _handleDobChange() {
    if (_dateOfBirthController.text.isEmpty) return;

    DateTime? dob = _parseDate(_dateOfBirthController.text);
    if (dob != null) {
      DateTime now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }

      if (age < 30) {
        _dateOfBirthController.clear();

        if (mounted) {
          SnackbarHelper.showError(
            context,
            message: "Age must be at least 30 years",
          );
        }
      }
    }
  }

  String _formatAadharData(String aadhar) {
    String clean = aadhar.replaceAll(' ', '');
    if (clean.length != 12) return aadhar;

    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      buffer.write(clean[i]);
      if ((i == 3 || i == 7) && i != clean.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  void _showGenderSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CustomColors.clrWhite,
          title: Text(
            "Select Gender",
            style: TextStyle(
              color: CustomColors.clrBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _genders.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _genders[index],
                    style: TextStyle(
                      color: CustomColors.clrBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    if (_genders[index] == 'Female') {
                      SnackbarHelper.showError(
                        context,
                        message: "You cannot select female",
                      );
                      return;
                    }

                    setState(() {
                      _genderController.text = _genders[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchActiveAreas() async {
    print('🚀 [MemberStepOne] _fetchActiveAreas calling...');
    final response = await MemberController.fetchActiveAreas();
    print('📦 [MemberStepOne] response success: ${response.isSuccess()}');

    if (response.isSuccess() && response.data != null) {
      if (mounted) {
        setState(() {
          // Handle case where data is a List or a Map containing a list
          if (response.data is List) {
            _activeAreas = response.data;
          } else if (response.data is Map) {
            // Check for common keys like 'areas', 'data', or 'items'
            _activeAreas =
                response.data['areas'] ??
                response.data['data'] ??
                response.data['items'] ??
                [];
          } else {
            _activeAreas = [];
          }
          print('✅ [MemberStepOne] Loaded ${_activeAreas.length} areas');
        });
      }
    } else {
      print('❌ [MemberStepOne] Failed to load areas: ${response.message}');
    }
  }

  void _copyCurrentToPermanent() {
    if (_sameAsPermanent) {
      setState(() {
        _permanentAddressLine1Controller.text =
            _currentAddressLine1Controller.text;
        _permanentAddressLine2Controller.text =
            _currentAddressLine2Controller.text;
        _permanentCityController.text = _currentCityController.text;
        _permanentStateController.text = _currentStateController.text;
        _permanentZipCodeController.text = _currentZipCodeController.text;
        _permanentCountryController.text = _currentCountryController.text;
      });
    } else {
      setState(() {
        _permanentAddressLine1Controller.clear();
        _permanentAddressLine2Controller.clear();
        _permanentCityController.clear();
        _permanentStateController.clear();
        _permanentZipCodeController.clear();
        _permanentCountryController.clear();
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _genderController.dispose();
    _aadharController.dispose();
    _fatherNameController.dispose();
    _janAadhaarController.dispose();
    _permanentAddressLine1Controller.dispose();
    _permanentAddressLine2Controller.dispose();
    _permanentCityController.dispose();
    _permanentStateController.dispose();
    _permanentZipCodeController.dispose();
    _permanentCountryController.dispose();
    _currentAddressLine1Controller.dispose();
    _currentAddressLine2Controller.dispose();
    _currentCityController.dispose();
    _currentStateController.dispose();
    _currentZipCodeController.dispose();
    _currentCountryController.dispose();
    _areaController.dispose();
    _numberOfYearsController.dispose();
    _dateOfBirthController.removeListener(_handleDobChange);
    super.dispose();
  }

  bool _validateForm() {
    if (_firstNameController.text.isEmpty) {
      SnackbarHelper.showError(context, message: 'First name is required');
      return false;
    }
    if (_lastNameController.text.isEmpty) {
      SnackbarHelper.showError(context, message: 'Last name is required');
      return false;
    }
    if (_genderController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please select gender");
      return false;
    }
    if (_genderController.text == 'Female') {
      SnackbarHelper.showError(context, message: "You cannot select female");
      return false;
    }
    if (_dateOfBirthController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter date of birth");
      return false;
    }

    // Age validation
    DateTime? dob = _parseDate(_dateOfBirthController.text);
    if (dob == null) {
      SnackbarHelper.showError(context, message: "Invalid date format");
      return false;
    }

    DateTime now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    if (age < 30) {
      SnackbarHelper.showError(
        context,
        message: "Age must be at least 30 years",
      );
      return false;
    }

    if (_aadharController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter Aadhar number");
      return false;
    }

    // Validate Aadhar is exactly 12 digits (after removing spaces)
    String cleanAadhar = _aadharController.text.replaceAll(' ', '');
    if (cleanAadhar.length != 12) {
      SnackbarHelper.showError(
        context,
        message: "Aadhar number must be 12 digits",
      );
      return false;
    }
    if (_janAadhaarController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter Jan Aadhaar ID");
      return false;
    }
    if (_phoneController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter phone number");
      return false;
    }
    if (_emailController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter email");
      return false;
    }
    if (_fatherNameController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter father name");
      return false;
    }
    if (_selectedAreaId == null || _selectedAreaId!.isEmpty) {
      SnackbarHelper.showError(context, message: "Please select area");
      return false;
    }
    if (_numberOfYearsController.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: "Please enter number of years",
      );
      return false;
    }

    // Permanent Address Validation
    if (_permanentAddressLine1Controller.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: "Please enter permanent address line 1",
      );
      return false;
    }
    if (_permanentCityController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter permanent city");
      return false;
    }
    if (_permanentStateController.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: "Please enter permanent state",
      );
      return false;
    }
    if (_permanentZipCodeController.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: "Please enter permanent zip code",
      );
      return false;
    }
    if (_permanentCountryController.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: "Please enter permanent country",
      );
      return false;
    }

    // Current Address Validation
    if (_currentAddressLine1Controller.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: "Please enter current address line 1",
      );
      return false;
    }
    if (_currentCityController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter current city");
      return false;
    }
    if (_currentStateController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter current state");
      return false;
    }
    if (_currentZipCodeController.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: "Please enter current zip code",
      );
      return false;
    }
    if (_currentCountryController.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: "Please enter current country",
      );
      return false;
    }

    return true;
  }

  Future<void> saveStepOneData() async {
    if (_validateForm()) {
      setState(() {
        _isLoading = true;
      });

      // Combine permanent address for backup/compatibility
      String permanentAddress =
          '${_permanentAddressLine1Controller.text}, ${_permanentAddressLine2Controller.text}, ${_permanentCityController.text}, ${_permanentStateController.text}, ${_permanentZipCodeController.text}, ${_permanentCountryController.text}';

      // Combine current address
      String currentAddress =
          '${_currentAddressLine1Controller.text}, ${_currentAddressLine2Controller.text}, ${_currentCityController.text}, ${_currentStateController.text}, ${_currentZipCodeController.text}, ${_currentCountryController.text}';

      // Remove spaces from Aadhar number before sending
      String cleanAadhar = _aadharController.text.replaceAll(' ', '');

      MembershipModel membership = MembershipModel(
        id: widget.applicationId ?? '',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        applicantName:
            '${_firstNameController.text} ${_lastNameController.text}',
        email: _emailController.text,
        aadhaarNumber: cleanAadhar,
        familyId: _janAadhaarController.text,
        status: 'Draft',
        submittedAt: '',
        gender: _genderController.text,
        dob: _dateOfBirthController.text,
        phone: _phoneController.text,
        phoneCode: '+91',
        currentAddress: currentAddress,
        area: _selectedAreaId != null ? AreaModel(id: _selectedAreaId!, name: '') : null,
        yearsInPermanentAddress: int.tryParse(_numberOfYearsController.text),
        permanentAddress: permanentAddress,
        permanentAddressLine1: _permanentAddressLine1Controller.text,
        permanentAddressLine2: _permanentAddressLine2Controller.text,
        permanentCity: _permanentCityController.text,
        permanentState: _permanentStateController.text,
        permanentZipCode: _permanentZipCodeController.text,
        permanentCountry: _permanentCountryController.text,
        currentAddressLine1: _currentAddressLine1Controller.text,
        currentAddressLine2: _currentAddressLine2Controller.text,
        currentCity: _currentCityController.text,
        currentState: _currentStateController.text,
        currentZipCode: _currentZipCodeController.text,
        currentCountry: _currentCountryController.text,
        fathersName: _fatherNameController.text,
        mode: 'ONLINE',
      );

      print('=== MEMBERSHIP API CALL START ===');
      final payload = membership.toJson();
      print('📡 [MemberStepOne] Request Payload: $payload');

      final response =
          (widget.applicationId != null && widget.applicationId!.isNotEmpty)
          ? await MemberController.editMembership(
              widget.applicationId!,
              payload,
            )
          : await MemberController.addMembershipDraft(membership);

      setState(() {
        _isLoading = false;
      });

      if (response.isSuccess()) {
        SnackbarHelper.show(context, message: "Draft saved successfully");
        if (widget.onStepComplete != null) {
          String id = '';
          if (response.data != null && response.data is Map) {
            id =
                response.data['_id']?.toString() ??
                response.data['id']?.toString() ??
                widget.applicationId ??
                '';
          } else {
            id = widget.applicationId ?? '';
          }
          widget.onStepComplete!(id);
        }
      } else {
        SnackbarHelper.showError(
          context,
          message: "Failed to save draft: ${response.message}",
        );
      }
      print('=== MEMBERSHIP API CALL END ===\n');
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: CustomColors.clrBlack,
          fontFamily: CustomFonts.poppins,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information Section
          _buildSectionHeader("Personal Information"),

          PrimaryInput(
            title: "First Name",
            hint: "Enter first name",
            controller: _firstNameController,
            keyboardType: TextInputType.text,
            suffixIcon: Icon(Icons.person, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          PrimaryInput(
            title: "Last Name",
            hint: "Enter last name",
            controller: _lastNameController,
            keyboardType: TextInputType.text,
            suffixIcon: Icon(Icons.person, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          // Gender Selection
          GestureDetector(
            onTap: _showGenderSelection,
            child: AbsorbPointer(
              child: SingleSlecectInput(
                title: "Gender",
                hint: _genderController.text.isEmpty
                    ? "Select your gender"
                    : _genderController.text,
                controller: _genderController,
                keyboardType: TextInputType.text,
                suffixIcon: Icon(Icons.keyboard_arrow_down, size: 30),
              ),
            ),
          ),
          SizedBox(height: 10),

          // Date of Birth
          DateInput(
            title: "Date of Birth",
            controller: _dateOfBirthController,
            suffixIcon: Icon(
              Icons.calendar_month,
              size: 24,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 10),

          // Aadhar Number
          PrimaryInput(
            title: "Aadhar Number",
            hint: "XXXX XXXX XXXX",
            controller: _aadharController,
            keyboardType: TextInputType.number,
            suffixIcon: Icon(Icons.badge, size: 24, color: Colors.grey),
            inputFormatters: [AadharInputFormatter()],
          ),
          SizedBox(height: 10),

          // Jan Aadhaar Family ID
          PrimaryInput(
            title: "Jan Aadhaar Family ID",
            hint: "Enter Jan Aadhaar Family ID",
            controller: _janAadhaarController,
            keyboardType: TextInputType.text,
            suffixIcon: Icon(
              Icons.family_restroom,
              size: 24,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 10),

          // Phone Number
          PrimaryInput(
            title: "Phone Number",
            hint: "Enter phone number",
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            suffixIcon: Icon(Icons.phone, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          // Email
          PrimaryInput(
            title: "Email",
            hint: "Enter your email",
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            suffixIcon: Icon(Icons.email, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          // Father name
          PrimaryInput(
            title: "Father's Name",
            hint: "Enter your father's name",
            controller: _fatherNameController,
            keyboardType: TextInputType.text,
            suffixIcon: Icon(
              Icons.person_outline,
              size: 24,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 10),

          // Area Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Area",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.clrBlack,
                      fontFamily: CustomFonts.poppins,
                    ),
                  ),
                  Text(
                    " *",
                    style: TextStyle(
                      color: CustomColors.clrRed,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _selectedAreaId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  suffixIcon: Icon(
                    Icons.location_city,
                    size: 24,
                    color: Colors.grey,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: CustomColors.clrborder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: CustomColors.clrborder,
                      width: 1.3,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                hint: Text(
                  "Select your area",
                  style: TextStyle(
                    color: CustomColors.clrInputText,
                    fontFamily: CustomFonts.poppins,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                items: _activeAreas.map((dynamic area) {
                  final name = area['name'] ?? area['title'] ?? 'Unknown Area';
                  final id = (area['_id'] ?? area['id'] ?? '').toString();
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(
                      name,
                      style: TextStyle(
                        fontFamily: CustomFonts.poppins,
                        color: CustomColors.clrBlack,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAreaId = newValue;
                    final selectedArea = _activeAreas.firstWhere((element) {
                      final id = element['_id'] ?? element['id'] ?? '';
                      return id == newValue;
                    }, orElse: () => null);

                    if (selectedArea != null) {
                      final name =
                          selectedArea['name'] ?? selectedArea['title'] ?? '';
                      _areaController.text = name;

                      // Also extract constituency if available
                      final constituency =
                          selectedArea['constituency'] ??
                          selectedArea['vidhansabha'] ??
                          selectedArea['constituencyName'] ??
                          '';
                    }
                  });
                },
              ),
            ],
          ),

          SizedBox(height: 10),

          PrimaryInput(
            title: "Years in Permanent Address",
            hint: "Enter number of years",
            controller: _numberOfYearsController,
            keyboardType: TextInputType.number,
            suffixIcon: Icon(
              Icons.calendar_today,
              size: 24,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 30),

          // Current Address Section
          _buildSectionHeader("Current Address"),

          PrimaryInput(
            title: "Address Line 1",
            hint: "House No., Street Name",
            controller: _currentAddressLine1Controller,
            keyboardType: TextInputType.streetAddress,
            suffixIcon: Icon(Icons.home, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          PrimaryInput(
            title: "Address Line 2",
            hint: "Apartment, Suite, etc.",
            controller: _currentAddressLine2Controller,
            keyboardType: TextInputType.streetAddress,
            suffixIcon: Icon(Icons.apartment, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          PrimaryInput(
            title: "City",
            hint: "City",
            controller: _currentCityController,
            keyboardType: TextInputType.text,
            suffixIcon: Icon(Icons.location_city, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          PrimaryInput(
            title: "State",
            hint: "State",
            controller: _currentStateController,
            keyboardType: TextInputType.text,
            suffixIcon: Icon(Icons.map, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          PrimaryInput(
            title: "Zip Code",
            hint: "Postal Code",
            controller: _currentZipCodeController,
            keyboardType: TextInputType.number,
            suffixIcon: Icon(
              Icons.markunread_mailbox,
              size: 24,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 10),

          PrimaryInput(
            title: "Country",
            hint: "Country",
            controller: _currentCountryController,
            keyboardType: TextInputType.text,
            suffixIcon: Icon(Icons.public, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          // Same as Current Address Checkbox
          Padding(
            padding: EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: _sameAsPermanent,
                  activeColor: CustomColors.clrBtnBg,
                  onChanged: (bool? value) {
                    setState(() {
                      _sameAsPermanent = value ?? false;
                      _copyCurrentToPermanent();
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _sameAsPermanent = !_sameAsPermanent;
                      _copyCurrentToPermanent();
                    });
                  },
                  child: Text(
                    "Same as current address",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.clrBlack,
                      fontFamily: CustomFonts.poppins,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          // Permanent Address Section
          _buildSectionHeader("Permanent Address"),

          PrimaryInput(
            title: "Address Line 1",
            hint: "House No., Street Name",
            controller: _permanentAddressLine1Controller,
            keyboardType: TextInputType.streetAddress,
            suffixIcon: Icon(Icons.home, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          PrimaryInput(
            title: "Address Line 2",
            hint: "Apartment, Suite, etc.",
            controller: _permanentAddressLine2Controller,
            keyboardType: TextInputType.streetAddress,
            suffixIcon: Icon(Icons.apartment, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          PrimaryInput(
            title: "City",
            hint: "City",
            controller: _permanentCityController,
            keyboardType: TextInputType.text,
            suffixIcon: Icon(Icons.location_city, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          PrimaryInput(
            title: "State",
            hint: "State",
            controller: _permanentStateController,
            keyboardType: TextInputType.text,
            suffixIcon: Icon(Icons.map, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),

          PrimaryInput(
            title: "Zip Code",
            hint: "Postal Code",
            controller: _permanentZipCodeController,
            keyboardType: TextInputType.number,
            suffixIcon: Icon(
              Icons.markunread_mailbox,
              size: 24,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 10),

          PrimaryInput(
            title: "Country",
            hint: "Country",
            controller: _permanentCountryController,
            keyboardType: TextInputType.text,
            suffixIcon: Icon(Icons.public, size: 24, color: Colors.grey),
          ),
          SizedBox(height: 30),

          ButtonWithIcon(
            label: "Save & Next",
            isLoading: _isLoading,
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            onTap: _isLoading
                ? () {}
                : () async {
                    await saveStepOneData();
                  },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
