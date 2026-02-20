import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/backend/member_controller.dart';
import 'package:nakoda_ji/apps/member/components/documnet_upload_card.dart';
import 'package:nakoda_ji/apps/member/screens/auth/widgets/status_badge.dart';
import 'package:nakoda_ji/backend/models/membership_model.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class DocumentStatusList extends StatefulWidget {
  final Map<String, dynamic>? reviewData;
  final String applicationId;
  final VoidCallback onSuccess;
  final MembershipModel? application;

  const DocumentStatusList({
    super.key,
    required this.reviewData,
    required this.applicationId,
    required this.onSuccess,
    this.application,
  });

  @override
  State<DocumentStatusList> createState() => _DocumentStatusListState();
}

class _DocumentStatusListState extends State<DocumentStatusList> {
  @override
  Widget build(BuildContext context) {
    // 1. Try to get documents from Review Data (contains status/remarks)
    List<dynamic> docs = widget.reviewData?['documents'] ?? [];
    
    // Debug print
    print("📄 DocumentStatusList: Found ${docs.length} docs in reviewData");
    if (docs.isNotEmpty) {
      print("First doc keys: ${docs.first.keys.toList()}");
      print("First doc review: ${docs.first['review']}");
    }

    // 2. If review data is empty, fallback to Application Data
    if (docs.isEmpty && widget.application?.documents != null) {
      print("⚠️ Review docs empty, using Application docs from model");
      docs = widget.application!.documents!.map((d) {
        // Log individual doc for debugging
        print("Mapping doc: ${d['originalName']} | Has Review: ${d['review'] != null}");
        
        return {
          'originalName': d['originalName'] ?? d['fileName'],
          'documentType': d['documentType'] ?? {
            'name': 'Document', 
            'id': d['documentTypeId'] ?? d['documentType']?['id'] ?? d['documentType']?['_id']
          },
          // CRITICAL FIX: Use the review object from the application model if it exists
          'review': d['review'] ?? {
            'status': d['status'] ?? 'PENDING', 
            'remark': d['remark'] ?? null
          },
          'documentTypeId': d['documentTypeId'] ?? d['documentType']?['id'] ?? d['documentType']?['_id'],
        };
      }).toList();
    }

    if (docs.isEmpty) {
       return Container(
         padding: const EdgeInsets.all(16),
         width: double.infinity,
         decoration: BoxDecoration(
           color: Colors.grey.shade50,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.grey.shade200),
         ),
         child: Column(
           children: [
             Icon(Icons.folder_off_outlined, size: 32, color: Colors.grey.shade400),
             const SizedBox(height: 8),
             Text(
               "No documents found",
               style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
             ),
           ],
         ),
       );
    } 

    return Column(
      children:
          docs.map((doc) {
            // Prioritize Document Type Name (e.g., "Aadhaar Card") over filename
            String name =
                doc['documentType']?['name'] ??
                doc['originalName'] ??
                'Document';
                
            // Ensure status is valid
            String status = doc['review']?['status']?.toString().toUpperCase() ?? 'PENDING';
            String? remark = doc['review']?['remark'];
            String? docTypeId =
                doc['documentType']?['_id'] ??
                doc['documentType']?['id'] ??
                doc['documentTypeId'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xffF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.file_copy_rounded,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            if (doc['originalName'] != null) // Show filename as subtitle if available
                              Text(
                                doc['originalName'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                        StatusBadge(status: status),
                      if (status == 'CHANGES_REQUESTED' && docTypeId != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.orange,
                          ),
                          onPressed: () => _handleDocumentReupload(
                            context,
                            docTypeId,
                            name,
                            remark,
                          ),
                          tooltip: "Re-upload document",
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ],
                  ),
                  if (remark != null && status != 'CHANGES_REQUESTED')
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 46),
                      child: Text(
                        remark,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Future<void> _handleDocumentReupload(
    BuildContext context,
    String docTypeId,
    String docName,
    String? remark,
  ) async {
    File? selectedFile;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setDialogState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: CustomColors.clrBtnBg.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.upload_file_rounded,
                              color: CustomColors.clrBtnBg,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Update Document",
                              style: const TextStyle(
                                fontFamily: CustomFonts.poppins,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: CustomColors.clrBtnBg,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed:
                                isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Remark Box
                      if (remark != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 20,
                                color: Colors.orange.shade800,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Admin Remark:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      remark,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      Text(
                        "Upload new $docName",
                        style: TextStyle(
                          fontFamily: CustomFonts.poppins,
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),

                      DocumentUploadCard(
                        title: docName,
                        subTitle: "Select file to upload",
                        isRequired: true,
                        onFileSelected: (file) {
                          setDialogState(() {
                            selectedFile = file;
                          });
                        },
                        initialUploaded: false, // Don't mark as "uploaded" yet, force user to pick NEW file
                        // We don't pass initialFileName here because we want them to pick a NEW one. 
                        // But user said "purnae wali file to show". 
                        // Let's show it in a Text widget above instead.
                      ),
                      
                      const SizedBox(height: 10),
                      Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           color: Colors.grey.shade100,
                           borderRadius: BorderRadius.circular(8),
                           border: Border.all(color: Colors.grey.shade300),
                         ),
                         child: Row(
                           children: [
                             const Icon(Icons.attachment_rounded, size: 16, color: Colors.grey),
                             const SizedBox(width: 8),
                             Expanded(
                               child: Text(
                                 "Current File: $docName",
                                 style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                           ],
                         ),
                      ),


                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (isSubmitting) return;

                            if (selectedFile == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Please select a file first"),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  setDialogState(() => isSubmitting = true);
                                  try {
                                    final response =
                                        await MemberController.uploadMembershipDocuments(
                                          applicationId: widget.applicationId,
                                          documents: [
                                            (
                                              documentTypeId: docTypeId,
                                              file: selectedFile!,
                                            ),
                                          ],
                                        );

                                    if (response.isSuccess()) {
                                      widget.onSuccess();
                                      Navigator.pop(context);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Document submitted successfully",
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } else {
                                      setDialogState(
                                        () => isSubmitting = false,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(response.message),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    setDialogState(
                                      () => isSubmitting = false,
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Error: $e"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.clrBtnBg,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isSubmitting) ...[
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Text(
                                isSubmitting ? "Submitting..." : "Submit Correction",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
