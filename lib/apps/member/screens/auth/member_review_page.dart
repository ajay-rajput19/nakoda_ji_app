import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/backend/member_controller.dart';
import 'package:nakoda_ji/backend/models/membership_model.dart';
import 'package:nakoda_ji/backend/models/backend_response.dart';
import 'package:nakoda_ji/components/buttons/button_with_icon.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/utils/localStorage/local_storage.dart';
import 'package:nakoda_ji/utils/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberReviewPage extends StatefulWidget {
  final String? applicationId;

  const MemberReviewPage({super.key, this.applicationId});

  @override
  State<MemberReviewPage> createState() => _MemberReviewPageState();
}

class _MemberReviewPageState extends State<MemberReviewPage> {
  bool _isLoading = true;
  MembershipModel? _membershipData;

  @override
  void initState() {
    super.initState();
    _fetchMembershipData();
  }

  Future<void> _fetchMembershipData() async {
    if (widget.applicationId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Application ID is missing')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await MemberController.getMembershipReviewProfile(
      widget.applicationId!,
    );

    if (response.isSuccess() && response.data != null) {
      // Extract membership data from response
      try {
        final membershipJson = response.data;

        if (membershipJson != null) {
          final membershipModel = MembershipModel.fromJson(membershipJson);

          if (mounted) {
            setState(() {
              _membershipData = membershipModel;
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error parsing membership data: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        // Show detailed error message
        String errorMessage = 'Failed to load membership data';
        if (response.message.isNotEmpty) {
          errorMessage = response.message;
        }
        if (response.detail != null && response.detail!.isNotEmpty) {
          errorMessage += ': ${response.detail}';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  Widget _buildPersonalInfoSection() {
    if (_membershipData == null) return SizedBox.shrink();

    // Temporary debug to check the applicant name
    print('DEBUG: Applicant Name = ${_membershipData!.applicantName}');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColors.clrborder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Application ID', _membershipData!.id),
          _buildInfoRow('Full Name', _membershipData!.applicantName),
          _buildInfoRow('Gender', _membershipData!.gender ?? 'Not provided'),
          _buildInfoRow(
            'Date of Birth',
            _membershipData!.dob ?? 'Not provided',
          ),
          _buildInfoRow('Aadhar Number', _membershipData!.aadhaarNumber),
          _buildInfoRow('Family ID', _membershipData!.familyId),
          _buildInfoRow(
            'Phone Number',
            _membershipData!.phone ?? 'Not provided',
          ),
          _buildInfoRow('Email', _membershipData!.email),
          _buildInfoRow(
            'Father\'s Name',
            _membershipData!.fathersName ?? 'Not provided',
          ),
          _buildInfoRow(
            'Current Address',
            _membershipData!.currentAddress ??
                _membershipData!.address ??
                'Not provided',
          ),
          _buildInfoRow(
            'Permanent Address',
            _membershipData!.permanentAddress ?? 'Not provided',
          ),
          _buildInfoRow(
            'Years at Permanent Address',
            _membershipData!.yearsInPermanentAddress?.toString() ??
                'Not provided',
          ),
          _buildInfoRow('Constituency', _membershipData!.constituency),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: CustomColors.clrborder, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: CustomColors.clrHeading,
                fontFamily: CustomFonts.poppins,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CustomColors.clrBlack,
                fontFamily: CustomFonts.poppins,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColors.clrborder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_membershipData?.documents == null ||
              _membershipData!.documents!.isEmpty)
            Center(
              child: Text(
                'No documents uploaded',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            ..._membershipData!.documents!.map((doc) {
              // Handle both direct document objects and nested document structures
              final documentData = doc is Map<String, dynamic>
                  ? doc
                  : (doc as dynamic)?.toJson() ?? {};

              String docName =
                  documentData['originalName'] ??
                  documentData['name'] ??
                  'Document';
              int docSize = documentData['size'] ?? 0;
              String docType =
                  documentData['documentType']?['name'] ??
                  documentData['type'] ??
                  'Document';
              String storageKey = documentData['storageKey'] ?? '';

              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            docType,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: CustomColors.clrHeading,
                              fontFamily: CustomFonts.poppins,
                            ),
                          ),
                          Text(
                            '$docName (${_formatFileSize(docSize)})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CustomColors.clrBlack,
                            ),
                          ),
                          if (storageKey.isNotEmpty)
                            Text(
                              'Storage: $storageKey',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.check, color: Colors.green, size: 20),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Custom small button for Edit actions
  Widget _buildEditButton(VoidCallback onTap) {
    return Container(
      height: 35,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CustomColors.clrBtnBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Edit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_membershipData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load membership data',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchMembershipData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Wrap in SingleChildScrollView to avoid layout constraint issues
    return SingleChildScrollView(
      // padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Review Your Application",
              style: TextStyle(
                color: CustomColors.clrBlack,
                fontWeight: FontWeight.w500,
                fontSize: 25,
                fontFamily: CustomFonts.poppins,
              ),
            ),
          ),
          SizedBox(height: 20),
          // Personal Information Section Header with Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: CustomColors.clrBtnBg, size: 25),
                  SizedBox(width: 8),
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CustomColors.clrBlack,
                      fontFamily: CustomFonts.poppins,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Implement navigation to edit personal info
                  SnackbarHelper.show(
                    context,
                    message: "Navigating to edit personal information",
                  );
                },
                child: _buildEditButton(() {
                  // TODO: Implement navigation to edit personal info
                  SnackbarHelper.show(
                    context,
                    message: "Navigating to edit personal information",
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildPersonalInfoSection(),
          SizedBox(height: 20),
          // Documents Section Header with Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_document,
                    color: CustomColors.clrBtnBg,
                    size: 25,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Uploaded Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CustomColors.clrBlack,
                      fontFamily: CustomFonts.poppins,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Implement navigation to edit documents
                  SnackbarHelper.show(
                    context,
                    message: "Navigating to edit documents",
                  );
                },
                child: _buildEditButton(() {
                  // TODO: Implement navigation to edit documents
                  SnackbarHelper.show(
                    context,
                    message: "Navigating to edit documents",
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildDocumentSection(),
          SizedBox(height: 30),
          ButtonWithIcon(
            label: "Submit Application",
            icon: Icon(Icons.send),
            onTap: () {
              // Handle submission
              SnackbarHelper.show(
                context,
                message: "Application submitted successfully!",
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
