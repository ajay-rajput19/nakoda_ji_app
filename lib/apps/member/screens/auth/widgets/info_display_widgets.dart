import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/screens/auth/widgets/edit_field_dialog.dart';
import 'package:nakoda_ji/apps/member/screens/auth/widgets/status_badge.dart';
import 'package:nakoda_ji/backend/models/membership_model.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class InfoSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const InfoSectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: CustomColors.clrBtnBg,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: Colors.grey.shade400, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: CustomFonts.poppins,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}

class InfoCategoryCard extends StatelessWidget {
  final List<Widget> children;

  const InfoCategoryCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class InfoItemRow extends StatelessWidget {
  final String label;
  final String? value;
  final String fieldName;
  final Map<String, dynamic>? reviewData;
  final String applicationId;
  final VoidCallback onSuccess;
  final MembershipModel? application;

  const InfoItemRow({
    super.key,
    required this.label,
    required this.value,
    required this.fieldName,
    required this.reviewData,
    required this.applicationId,
    required this.onSuccess,
    this.application,
  });

  @override
  Widget build(BuildContext context) {
    String status = _getFieldStatus(fieldName);
    String? remark = _getFieldRemark(fieldName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value ?? "N/A",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              if (status == 'CHANGES_REQUESTED')
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.orange),
                  onPressed:
                      () => EditFieldDialog.show(
                        context: context,
                        applicationId: applicationId,
                        fieldName: fieldName,
                        currentValue: value ?? "",
                        label: label,
                        remark: remark,
                        onSuccess: onSuccess,
                      ),
                  tooltip: "Correct this field",
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFieldStatus(String fieldName) {
    // 1. Check Review Data Map
    List<dynamic> fields = reviewData?['fieldReviews'] ?? [];
    var review = fields.firstWhere(
      (f) => f['fieldName'] == fieldName,
      orElse: () => null,
    );

    // 2. Fallback to Application Model's fieldReviews
    if (review == null && application?.fieldReviews != null) {
      review = application!.fieldReviews!.firstWhere(
        (f) => f['fieldName'] == fieldName,
        orElse: () => null,
      );
    }

    return review?['status'] ?? 'PENDING';
  }

  String? _getFieldRemark(String fieldName) {
    // 1. Check Review Data Map
    List<dynamic> fields = reviewData?['fieldReviews'] ?? [];
    var review = fields.firstWhere(
      (f) => f['fieldName'] == fieldName,
      orElse: () => null,
    );

    // 2. Fallback to Application Model's fieldReviews
    if (review == null && application?.fieldReviews != null) {
      review = application!.fieldReviews!.firstWhere(
        (f) => f['fieldName'] == fieldName,
        orElse: () => null,
      );
    }

    return review?['remark'];
  }
}
