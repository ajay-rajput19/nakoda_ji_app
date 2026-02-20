import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/backend/member_controller.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_status_page.dart';
import 'package:nakoda_ji/backend/models/membership_model.dart';
import 'package:nakoda_ji/components/buttons/button_with_icon.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';
import 'package:nakoda_ji/utils/localStorage/local_storage.dart';
import 'package:nakoda_ji/utils/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MemberReviewPage extends StatefulWidget {
  final String? applicationId;
  final bool isReviewMode;
  final Function(int step)? onEditStep;

  const MemberReviewPage({
    super.key,
    this.applicationId,
    this.isReviewMode = false,
    this.onEditStep,
  });

  @override
  State<MemberReviewPage> createState() => _MemberReviewPageState();
}

class _MemberReviewPageState extends State<MemberReviewPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  MembershipModel? _membershipData;
  bool _isConfirmed = false;

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

    final response = await MemberController.fetchMembershipById(
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
      } catch (e, stack) {
        print('❌ [MemberReviewPage] Parsing Error: $e');
        print('❌ [MemberReviewPage] Stack Trace: $stack');
        if (mounted) {
          setState(() => _isLoading = false);
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error parsing membership data: $e')),
          );
        }
      }
    } else {
      print('❌ [MemberReviewPage] API Error: ${response.message}');
      print('❌ [MemberReviewPage] API Detail: ${response.detail}');
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

  Future<void> _submitApplication() async {
    if (widget.applicationId == null) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await MemberController.submitMembership({
        'id': widget.applicationId,
      });

      if (response.isSuccess()) {
        // Clear saved registration data
        // Clear saved registration steps but KEEP the application ID for status tracking
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove(LocalStorage.memberRegistrationStep);
        // await prefs.remove(LocalStorage.memberRegistrationApplicationId); // KEEP THIS!
        await prefs.remove(LocalStorage.memberRegistrationSelectedOption);

        // Mark that user has a submitted application
        await prefs.setBool('hasMembershipApplication', true);

        print('✅ [MemberReviewPage] Submission Success!');
        print('✅ [MemberReviewPage] hasMembershipApplication set to TRUE');
        print(
          '✅ [MemberReviewPage] App ID kept: ${prefs.getString(LocalStorage.memberRegistrationApplicationId)}',
        );

        if (mounted) {
          // Show auto-dismissing success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: CustomColors.clrWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  SizedBox(height: 16),
                  Text(
                    "Success!",
                    style: TextStyle(
                      color: CustomColors.clrBlack,
                      fontWeight: FontWeight.bold,
                      fontFamily: CustomFonts.poppins,
                    ),
                  ),
                ],
              ),
              content: Text(
                "Your membership application has been submitted successfully and is now under review.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CustomColors.clrBlack,
                  fontFamily: CustomFonts.poppins,
                ),
              ),
            ),
          );

          // Wait for 2.5 seconds then navigate to Status Page
          await Future.delayed(const Duration(milliseconds: 2500));
          if (mounted) {
            Navigator.of(context).pop(); // Close Success Dialog

            // Navigate to Status Page as membership is now SUBMITTED
            AppNavigation(context).pushReplacement(
              MemberStatusPage(
                applicationId: widget.applicationId!,
                onEdit: () {
                  // This part is for going back to draft mode if needed
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MemberReviewPage(isReviewMode: true),
                    ),
                  );
                },
              ),
            );
          }
        }
      } else {
        if (mounted) {
          SnackbarHelper.showError(
            context,
            message: "Submission failed: ${response.message}",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          message: "An error occurred during submission",
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Not provided';
    if (date.contains('/')) return date; // Already formatted
    try {
      DateTime dt = DateTime.parse(date);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (e) {
      return date.split('T')[0];
    }
  }

  String _formatAadhar(String? aadhar) {
    if (aadhar == null || aadhar.isEmpty) return 'Not provided';
    String clean = aadhar.replaceAll(' ', '');
    if (clean.length == 12) {
      return "${clean.substring(0, 4)} ${clean.substring(4, 8)} ${clean.substring(8, 12)}";
    }
    return aadhar; // Return as is if format is unknown
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
          _buildInfoRow('Date of Birth', _formatDate(_membershipData!.dob)),
          _buildInfoRow(
            'Aadhar Number',
            _formatAadhar(_membershipData!.aadhaarNumber),
          ),
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
          _buildInfoRow('Area', _membershipData!.area?.name ?? 'Not provided'),
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
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
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
              value ?? 'Not provided',
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
    if (_isLoading || _isSubmitting) {
      return _buildSkeleton();
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

    final bool canEdit =
        widget.isReviewMode &&
        (_membershipData?.status?.toUpperCase() == 'DRAFT' ||
            _membershipData?.status?.toUpperCase() == 'REJECTED' ||
            _membershipData?.status == null ||
            _membershipData?.status?.isEmpty == true);

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
          // if (!canEdit) ...[
          //    SizedBox(height: 10),
          //    Container(
          //      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          //      decoration: BoxDecoration(
          //        color: _membershipData?.status?.toUpperCase() == 'APPROVED' ? Colors.green.shade50 : Colors.blue.shade50,
          //        borderRadius: BorderRadius.circular(8),
          //        border: Border.all(color: _membershipData?.status?.toUpperCase() == 'APPROVED' ? Colors.green : Colors.blue),
          //      ),
          //      child: Row(
          //        children: [
          //          Icon(Icons.info_outline, color: _membershipData?.status?.toUpperCase() == 'APPROVED' ? Colors.green : Colors.blue),
          //          SizedBox(width: 10),
          //          Expanded(
          //            child: Text(
          //              "Application Status: ${_membershipData?.status ?? 'Submitted'}",
          //              style: TextStyle(
          //                fontWeight: FontWeight.w600,
          //                color: _membershipData?.status?.toUpperCase() == 'APPROVED' ? Colors.green : Colors.blue,
          //              ),
          //            ),
          //          ),
          //        ],
          //      ),
          //    ),
          // ],
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
              if (canEdit)
                GestureDetector(
                  onTap: () {
                    if (widget.onEditStep != null) {
                      widget.onEditStep!(0); // Go to Step 1
                    }
                  },
                  child: _buildEditButton(() {
                    if (widget.onEditStep != null) {
                      widget.onEditStep!(0);
                    }
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
              if (canEdit)
                GestureDetector(
                  onTap: () {
                    if (widget.onEditStep != null) {
                      widget.onEditStep!(1); // Go to Step 2
                    }
                  },
                  child: _buildEditButton(() {
                    if (widget.onEditStep != null) {
                      widget.onEditStep!(1);
                    }
                  }),
                ),
            ],
          ),
          SizedBox(height: 10),
          _buildDocumentSection(),
          if (canEdit) ...[
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isConfirmed,
                  activeColor: CustomColors.clrBtnBg,
                  onChanged: (value) {
                    setState(() {
                      _isConfirmed = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    "I hereby declare that all the information provided above is true and correct to the best of my knowledge.",
                    style: TextStyle(
                      fontFamily: CustomFonts.poppins,
                      fontSize: 13,
                      color: CustomColors.clrBlack,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            ButtonWithIcon(
              label: "Submit Application",
              icon: Icon(Icons.send, color: Colors.white),
              isDisabled: !_isConfirmed,
              onTap: _submitApplication,
            ),
          ],
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 200,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Status Bar Skeleton
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 30),
            // Personal Info Header Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  width: 60,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Personal Info Card Skeleton
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(height: 30),
            // Documents Header Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  width: 60,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Documents Card Skeleton
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(height: 30),
            // Checkbox and Button Skeleton
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
