import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/components/documnet_upload_card.dart';
import 'package:nakoda_ji/components/buttons/button_with_icon.dart';

class UploadDocumentPage extends StatefulWidget {
  final Function()? onStepComplete;
  final Function()? onBack;

  const UploadDocumentPage({super.key, this.onStepComplete, this.onBack});

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  File? aadhaarFile;
  File? panFile;
  File? photoFile;
  File? signatureFile;
  File? address;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DocumentUploadCard(
            title: "Aadhaar Card",
            subTitle: "Upload PDF or JPG format (Max 5MB)",
            isRequired: true,
            onFileSelected: (file) {
              setState(() {
                aadhaarFile = file;
              });
              print("Aadhaar File Selected: $file");
            },
          ),
          SizedBox(height: 20),
          DocumentUploadCard(
            title: "Adress Proof",
            subTitle: "Upload PDF or JPG format (Max 5MB)",
            isRequired: true,
            onFileSelected: (file) {
              setState(() {
                address = file;
              });
              print("address File Selected: $file");
            },
          ),
          SizedBox(height: 30),

          ButtonWithIcon(
            label: "Save & Next",
            icon: Icon(Icons.arrow_forward),
            onTap: () {
              if (widget.onStepComplete != null) {
                widget.onStepComplete!();
              }
         
            },
          ),
        ],
      ),
    );
  }
}
