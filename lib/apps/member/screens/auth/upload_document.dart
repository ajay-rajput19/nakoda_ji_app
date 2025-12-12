import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/components/documnet_upload_card.dart';
import 'package:nakoda_ji/components/buttons/button_with_icon.dart';
import 'package:nakoda_ji/apps/member/backend/member_controller.dart';
import 'package:nakoda_ji/utils/snackbar_helper.dart';

class UploadDocumentPage extends StatefulWidget {
  final Function()? onStepComplete;
  final Function()? onBack;
  final String applicationId;

  const UploadDocumentPage({
    super.key, 
    this.onStepComplete, 
    this.onBack,
    required this.applicationId,
  });

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  bool _isLoading = true;
  List<dynamic> _documentTypes = [];
  final Map<String, bool> _uploadedStatus = {};
  final Map<String, File> _selectedFiles = {};
  final Map<String, bool> _uploadInProgress = {};

  @override
  void initState() {
    super.initState();
    _fetchDocumentTypes();
  }

  Future<void> _fetchDocumentTypes() async {
    setState(() => _isLoading = true);
    final response = await MemberController.fetchAllDocumentTypes();
    if (response.isSuccess() && response.data != null) {
      if (mounted) {
        setState(() {
          _documentTypes = response.data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        // Handle error?
      }
    }
  }

  Future<void> _handleFileUpload(String documentTypeId, File? file) async {
    if (file == null) {
      // Handle file removal if needed (e.g. clear state)
      setState(() {
        _selectedFiles.remove(documentTypeId);
        _uploadedStatus.remove(documentTypeId);
        _uploadInProgress.remove(documentTypeId);
      });
      return;
    }

    // 1. Set file locally and mark upload as in progress
    setState(() {
      _selectedFiles[documentTypeId] = file;
      _uploadInProgress[documentTypeId] = true;
    });

    // 2. Upload immediately
    try {
      final response = await MemberController.uploadMembershipDocuments(
        applicationId: widget.applicationId,
        documents: [(documentTypeId: documentTypeId, file: file)],
      );

      if (response.isSuccess()) {
        if (mounted) {
          setState(() {
            _uploadedStatus[documentTypeId] = true;
            _uploadInProgress.remove(documentTypeId);
          });
          SnackbarHelper.show(
            context,
            message: 'Document uploaded successfully',
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _uploadInProgress.remove(documentTypeId);
          });
          SnackbarHelper.show(
            context,
            message: 'Failed to upload document: ${response.message}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadInProgress.remove(documentTypeId);
        });
        SnackbarHelper.show(
          context,
          message: 'An error occurred while uploading the document',
        );
      }
    }
  }

  void _onNext() {
    // Show that the button was clicked
    SnackbarHelper.show(
      context,
      message: 'Saving documents...',
    );
    
    // Check required docs
    bool allRequiredUploaded = true;
    for (var doc in _documentTypes) {
      bool isRequired = doc['isRequired'] ?? false;
      String id = doc['_id'] ?? doc['id'];
      if (isRequired && (_uploadedStatus[id] != true)) {
        allRequiredUploaded = false;
        break;
      }
    }

    if (!allRequiredUploaded) {
      SnackbarHelper.showError(
        context,
        message: 'Please upload all required documents before proceeding.',
      );
      return;
    }

    if (widget.onStepComplete != null) {
      widget.onStepComplete!();
      // Show success message
      SnackbarHelper.show(
        context,
        message: 'Documents saved successfully!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_documentTypes.isEmpty) {
      return const Center(child: Text("No document requirements found."));
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._documentTypes.map((docType) {
            String title = docType['name'] ?? 'Document';
            String id = docType['_id'] ?? docType['id'];
            bool isRequired = docType['isRequired'] ?? false;
            List<dynamic>? allowedTypes = docType['allowedMimeTypes'];
            String subTitle = "Upload ${allowedTypes?.join(', ') ?? 'file'}";

            return Column(
              children: [
                DocumentUploadCard(
                  title: title,
                  subTitle: subTitle,
                  isRequired: isRequired,
                  onFileSelected: (file) => _handleFileUpload(id, file),
                ),
                if (_uploadedStatus[id] == true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 5),
                        Text(
                          "Uploaded",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            );
          }),

          const SizedBox(height: 30),

          ButtonWithIcon(
            label: "Save & Next",
            icon: const Icon(Icons.arrow_forward),
            onTap: _onNext,
          ),
        ],
      ),
    );
  }
}