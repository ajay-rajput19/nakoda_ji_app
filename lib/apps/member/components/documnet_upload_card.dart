import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DocumentUploadCard extends StatefulWidget {
  final String title;
  final String subTitle;
  final bool isRequired;
  final Function(File?) onFileSelected;

  const DocumentUploadCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.isRequired,
    required this.onFileSelected,
  });

  @override
  State<DocumentUploadCard> createState() => _DocumentUploadCardState();
}

class _DocumentUploadCardState extends State<DocumentUploadCard> {
  File? selectedFile;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
      widget.onFileSelected(selectedFile);
    }
  }

  // Function to clear selected file
  void clearFile() {
    setState(() {
      selectedFile = null;
    });
    widget.onFileSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---- Title Row ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (widget.isRequired)
                const Text(
                  "Required",
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            widget.subTitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 15),

          /// Upload Box
          GestureDetector(
            onTap: selectedFile == null ? pickFile : null,
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: selectedFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 40,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Drag and drop your file here",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          "or click to browse files",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Choose File",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        // Preview of selected file
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Check if it's an image file
                            if (selectedFile!.path.toLowerCase().endsWith(
                                  '.jpg',
                                ) ||
                                selectedFile!.path.toLowerCase().endsWith(
                                  '.jpeg',
                                ) ||
                                selectedFile!.path.toLowerCase().endsWith(
                                  '.png',
                                ))
                              Container(
                                height: 200,

                                margin: EdgeInsets.all(8),

                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  image: DecorationImage(
                                    image: FileImage(selectedFile!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              // For PDF or other file types
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 40,
                                    color: Colors.red.shade300,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    selectedFile!.path.split('/').last,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                          ],
                        ),
                        // Cancel button in top right corner
                        Positioned(
                          top: 1,
                          right: 1,
                          child: GestureDetector(
                            onTap: clearFile,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
