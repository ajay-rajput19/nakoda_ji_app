import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentUploadCard extends StatefulWidget {
  final String title;
  final String subTitle;
  final bool isRequired;
  final Function(File?) onFileSelected;
  final bool initialUploaded;
  final String? initialFileName;

  const DocumentUploadCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.isRequired,
    required this.onFileSelected,
    this.initialUploaded = false,
    this.initialFileName,
  });

  @override
  State<DocumentUploadCard> createState() => _DocumentUploadCardState();
}

class _DocumentUploadCardState extends State<DocumentUploadCard> {
  File? selectedFile;
  late bool isUploaded;

  @override
  void initState() {
    super.initState();
    isUploaded = widget.initialUploaded;
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        isUploaded = false; // Reset upload status when new file is selected
      });
      // Don't call onFileSelected here, only when user explicitly clicks upload
    }
  }

  // Function to upload the selected file
  void uploadFile() {
    if (selectedFile != null) {
      widget.onFileSelected(selectedFile);
      setState(() {
        isUploaded = true;
      });
    }
  }

  // Function to clear selected file
  void clearFile() {
    setState(() {
      selectedFile = null;
      isUploaded = false;
    });
    widget.onFileSelected(null);
  }

  // Function to preview the selected file
  void previewFile() {
    if (selectedFile != null) {
      // For images, show in a dialog
      if (selectedFile!.path.toLowerCase().endsWith('.jpg') ||
          selectedFile!.path.toLowerCase().endsWith('.jpeg') ||
          selectedFile!.path.toLowerCase().endsWith('.png')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      title: Text(widget.title),
                      backgroundColor: CustomColors.clrBtnBg,
                      foregroundColor: Colors.white,
                      actions: [
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Expanded(
                      child: InteractiveViewer(
                        child: Image.file(selectedFile!, fit: BoxFit.contain),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
      // For PDF files, show PDF preview
      else if (selectedFile!.path.toLowerCase().endsWith('.pdf')) {
        try {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                  backgroundColor: CustomColors.clrBtnBg,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                body: SfPdfViewer.file(selectedFile!),
              );
            },
          );
        } catch (e) {
          // Fallback if PDF viewer fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Unable to preview PDF. Please upload the file."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColors.clrborder, width: 1),
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
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
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
          Container(
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
                ? (isUploaded && widget.initialFileName != null)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 40,
                            color: Colors.green.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.initialFileName!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            "Already Uploaded",
                            style: TextStyle(fontSize: 13, color: Colors.green),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: pickFile,
                            icon: Icon(Icons.refresh),
                            label: Text("Replace File"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.clrBtnBg,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Column(
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
                          ElevatedButton.icon(
                            onPressed: pickFile,
                            icon: Icon(Icons.folder_open),
                            label: Text("Choose File"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.clrBtnBg,
                              foregroundColor: Colors.white,
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
                              selectedFile!.path.toLowerCase().endsWith('.png'))
                            Container(
                              height: 150,
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
                                    color: CustomColors.clrBlack,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${(selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CustomColors.clrHeading,
                                  ),
                                ),
                              ],
                            ),
                          // Action buttons
                          if (selectedFile != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: previewFile,
                                    icon: Icon(Icons.visibility),
                                    label: Text("Preview"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: CustomColors.clrBtnBg,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed: isUploaded ? null : uploadFile,
                                    icon: Icon(
                                      isUploaded ? Icons.check : Icons.upload,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      isUploaded ? "Uploaded" : "Upload",
                                      style: TextStyle(
                                        color: CustomColors.clrWhite,
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.resolveWith<
                                            Color
                                          >((Set<WidgetState> states) {
                                            return CustomColors.clrBtnBg;
                                          }),
                                      foregroundColor:
                                          WidgetStateProperty.resolveWith<
                                            Color
                                          >((Set<WidgetState> states) {
                                            return Colors.white;
                                          }),
                                    ),
                                  ),
                                ],
                              ),
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
                      // Upload status indicator
                    ],
                  ),
          ),
          if (isUploaded)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "✓ File uploaded successfully",
                style: TextStyle(color: Colors.green, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
