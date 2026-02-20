import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'VERIFIED':
        color = const Color(0xff10B981);
        icon = Icons.check_circle_rounded;
        break;
      case 'REJECTED':
        color = const Color(0xffEF4444);
        icon = Icons.cancel_rounded;
        break;
      case 'CHANGES_REQUESTED':
        color = const Color(0xffF97316); // Orange
        icon = Icons.edit_note_rounded;
        break;
      case 'SUBMITTED':
      case 'PENDING':
      case 'UNDER_REVIEW':
        color = const Color(0xff3B82F6); // Blue
        icon = Icons.access_time_filled_rounded;
        break;
      case 'DRAFT':
        color = Colors.grey;
        icon = Icons.edit_document;
        break;
      default:
        color = const Color(0xffF59E0B);
        icon = Icons.access_time_filled_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase().replaceAll('_', ' '),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
