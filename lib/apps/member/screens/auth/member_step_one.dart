import 'package:flutter/material.dart';
import 'package:nakoda_ji/components/buttons/button_with_icon.dart';
import 'package:nakoda_ji/components/inputs/date_input.dart';
import 'package:nakoda_ji/components/inputs/primary_input.dart';
import 'package:nakoda_ji/components/inputs/text_area_input.dart';
import 'package:nakoda_ji/components/inputs/single_slecect_input.dart';
import 'package:nakoda_ji/apps/member/backend/member_controller.dart';
import 'package:nakoda_ji/backend/models/membership_model.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/utils/snackbar_helper.dart';

class MemberStepOne extends StatefulWidget {
  final Function()? onStepComplete;

  const MemberStepOne({super.key, this.onStepComplete});

  @override
  State<MemberStepOne> createState() => _MemberStepOneState();
}

class _MemberStepOneState extends State<MemberStepOne> {
  // Controllers for form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _permanentAddressController =
      TextEditingController();

  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _numberOfYearsController =
      TextEditingController();
  final TextEditingController _janAadhaarController = TextEditingController();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  List<dynamic> _activeAreas = [];

  @override
  void initState() {
    super.initState();
    _fetchActiveAreas();
    _dateOfBirthController.addListener(_handleDobChange);
  }

  void _handleDobChange() {
    if (_dateOfBirthController.text.isEmpty) return;

    try {
      DateTime dob = DateTime.parse(_dateOfBirthController.text);
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
    } catch (e) {
      // Ignore parse errors or handle if necessary
    }
  }

  // Function to show gender selection dialog
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
          content: Container(
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
    final response = await MemberController.fetchActiveAreas();
    if (response.isSuccess() && response.data != null) {
      if (mounted) {
        setState(() {
          _activeAreas = response.data;
        });
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  String? _selectedAreaId;

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _permanentAddressController.dispose();
    _genderController.dispose();
    _aadharController.dispose();
    _janAadhaarController.dispose();
    _fatherNameController.dispose();
    _areaController.dispose();
    _numberOfYearsController.dispose();
    // Remove listener
    _dateOfBirthController.removeListener(_handleDobChange);

    super.dispose();
  }

  // Function to validate form
  bool _validateForm() {
    // Check if all required fields are filled
    if (_fullNameController.text.isEmpty) {
      SnackbarHelper.showError(context, message: 'Full name is required');
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
    try {
      DateTime dob = DateTime.parse(_dateOfBirthController.text);
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
    } catch (e) {
      SnackbarHelper.showError(context, message: "Invalid date format");
      return false;
    }

    if (_aadharController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter Aadhar number");
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
    if (_addressController.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: "Please enter current address",
      );
      return false;
    }
    if (_permanentAddressController.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: "Please enter permanent address",
      );
      return false;
    }
    if (_fatherNameController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter father name");
      return false;
    }
    if (_addressController.text.isEmpty) {
      SnackbarHelper.showError(context, message: "Please enter select area");
      return false;
    }
    if (_numberOfYearsController.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        message: "Please enter number of years",
      );
      return false;
    }

    return true;
  }

  Future<void> saveStepOneData() async {
    if (_validateForm()) {
      // Create membership object
      MembershipModel membership = MembershipModel(
        id: '', 
        applicantName: _fullNameController.text,
        email: _emailController.text,
        aadhaarNumber: _aadharController.text,
        familyId: _janAadhaarController.text,
        constituency: '',
        status: '', // Let backend handle default
        submittedAt: '', // Let backend handle
        gender: _genderController.text,
        dob: _dateOfBirthController.text,
        phone: _phoneController.text,
        address: null, // Don't send this, use currentAddress
        currentAddress: _addressController.text,
        areaId: _selectedAreaId ?? '', // Ensure empty string if null, though validation checks it
        yearsInPermanentAddress: int.tryParse(_numberOfYearsController.text),
        permanentAddress: _permanentAddressController.text,
        fathersName: _fatherNameController.text,
        mode: 'ONLINE', 
      );

      // Call API
      final response = await MemberController.addMembershipDraft(membership);

      if (response.isSuccess()) {
        SnackbarHelper.show(context, message: "Draft saved successfully");
        if (widget.onStepComplete != null) {
          widget.onStepComplete!();
        }
      } else {
        print("Failed to save draft");
        print(response.message);
        SnackbarHelper.showError(
          context,
          message:
              "Failed to save draft: ${response.message ?? 'Unknown error'}",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Name
            PrimaryInput(
              title: "Full Name",
              hint: "Enter first name",
              controller: _fullNameController,
              keyboardType: TextInputType.text,
              suffixIcon: Icon(Icons.person, size: 30),
            ),

            SizedBox(height: 20),

            // Gender Selection using SingleSlecectInput
            // Gender Selection using SingleSlecectInput
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
                  suffixIcon: Icon(Icons.keyboard_arrow_down, size: 35),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Date of Birth
            DateInput(
              title: "Date of Birth",
              controller: _dateOfBirthController,
              suffixIcon: Icon(Icons.calendar_month, size: 30),
            ),
            SizedBox(height: 20),

            // Aadhar Number
            PrimaryInput(
              title: "Aadhar Number",
              hint: "Enter 12-digit Aadhaar number",
              controller: _aadharController,
              keyboardType: TextInputType.number,
              suffixIcon: Icon(Icons.file_copy, size: 30),
            ),
            SizedBox(height: 20),

            // Jan Aadhaar Family ID
            PrimaryInput(
              title: "Jan Aadhaar Family ID",
              hint: "Enter Jan Aadhaar Family ID",
              controller: _janAadhaarController,
              keyboardType: TextInputType.text,
              suffixIcon: Icon(Icons.person_sharp, size: 30),
            ),
            SizedBox(height: 20),

            // Phone Number
            PrimaryInput(
              title: "Phone Number",
              hint: "Enter phone number",
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),

            // Email
            PrimaryInput(
              title: "Email",
              hint: "Enter your email",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              suffixIcon: Icon(Icons.email, size: 30),
            ),
            SizedBox(height: 20),
            // Father name
            PrimaryInput(
              title: "Father name",
              hint: "Enter your father name",
              controller: _fatherNameController,
              keyboardType: TextInputType.text,
              suffixIcon: Icon(Icons.email, size: 30),
            ),
            SizedBox(height: 20),
            // Area Selection using DropdownButtonFormField
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
                    final name =
                        area['name'] ?? area['title'] ?? 'Unknown Area';
                    final id = area['_id'] ?? area['id'] ?? '';
                    return DropdownMenuItem<String>(
                      value: id as String,
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
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            PrimaryInput(
              title: "Number of Years ",
              hint: "Enter number of years",
              controller: _numberOfYearsController,
              keyboardType: TextInputType.number,
              suffixIcon: Icon(Icons.email, size: 30),
            ),
            SizedBox(height: 20),

            // Current Address
            TextAreaInput(
              title: "Current Address",
              hint: "Enter current address",
              suffixIcon: Icon(Icons.location_on, size: 30),
              controller: _addressController,
            ),
            const SizedBox(height: 20),

            // Permanent Address
            TextAreaInput(
              title: "Permanent Address",
              hint: "Enter permanent address",
              controller: _permanentAddressController,
              suffixIcon: Icon(Icons.location_on, size: 30),
            ),

            const SizedBox(height: 20),
            ButtonWithIcon(
              label: "Save & Next",
              icon: Icon(Icons.arrow_forward),
              onTap: () async {
                await saveStepOneData();
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
