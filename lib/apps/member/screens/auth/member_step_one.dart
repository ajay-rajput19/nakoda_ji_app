import 'package:flutter/material.dart';
import 'package:nakoda_ji/components/buttons/button_with_icon.dart';
import 'package:nakoda_ji/components/inputs/date_input.dart';
import 'package:nakoda_ji/components/inputs/primary_input.dart';
import 'package:nakoda_ji/components/inputs/single_slecect_input.dart';
import 'package:nakoda_ji/components/inputs/text_area_input.dart';

class MemberStepOne extends StatefulWidget {
  final Function()? onStepComplete;

  const MemberStepOne({super.key, this.onStepComplete});

  @override
  State<MemberStepOne> createState() => _MemberStepOneState();
}

class _MemberStepOneState extends State<MemberStepOne> {
  // Controllers for form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _permanentAddressController =
      TextEditingController();

  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _janAadhaarController = TextEditingController();

  final List<String> _genders = ['Male', 'Female', 'Other'];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _permanentAddressController.dispose();

    _genderController.dispose();
    _aadharController.dispose();
    _janAadhaarController.dispose();
    super.dispose();
  }

  // Function to show gender selection dialog
  void _showGenderSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Gender"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _genders.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_genders[index]),
                  onTap: () {
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

  // Function to validate form
  // bool _validateForm() {
  //   // Check if all required fields are filled
  //   if (_firstNameController.text.isEmpty) {
  //     return false;
  //   }
  //   if (_genderController.text.isEmpty) {
  //     return false;
  //   }
  //   if (_dateOfBirthController.text.isEmpty) {
  //     return false;
  //   }
  //   if (_aadharController.text.isEmpty) {
  //     return false;
  //   }
  //   if (_janAadhaarController.text.isEmpty) {
  //     return false;
  //   }
  //   if (_phoneController.text.isEmpty) {
  //     return false;
  //   }
  //   if (_emailController.text.isEmpty) {
  //     return false;
  //   }
  //   if (_addressController.text.isEmpty) {
  //     return false;
  //   }
  //   if (_permanentAddressController.text.isEmpty) {
  //     return false;
  //   }

  //   return true;
  // }

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
              title: "First Name",
              hint: "Enter first name",
              controller: _firstNameController,
              keyboardType: TextInputType.text,
              suffixIcon: Icon(Icons.person, size: 30),
            ),

            SizedBox(height: 20),

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
              onTap: () {
                if (widget.onStepComplete != null) {
                  widget.onStepComplete!();
                }
                // if (_validateForm()) {
                //   // Form is valid, notify parent to move to next step
                //   if (widget.onStepComplete != null) {
                //     widget.onStepComplete!();
                //   }
                // } else {
                //   // Show error message
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text("Please fill all required fields"),
                //       backgroundColor: CustomColors.clrRed,
                //     ),
                //   );
                // }
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
