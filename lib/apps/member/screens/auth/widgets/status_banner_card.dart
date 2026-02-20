import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class StatusBannerCard extends StatelessWidget {
  final String status;
  final VoidCallback? onEdit;

  const StatusBannerCard({super.key, required this.status, this.onEdit});

  @override
  Widget build(BuildContext context) {
    bool needsChanges = status == 'REJECTED' || status == 'CHANGES_REQUESTED';

    Color baseColor;
    IconData icon;
    String title;
    List<Color> gradient;

    switch (status) {
      case 'APPROVED':
        baseColor = const Color(0xff10B981);
        icon = Icons.verified_user_rounded;
        title = "Application Approved";
        gradient = [const Color(0xff10B981), const Color(0xff059669)];
        break;
      case 'REJECTED':
      case 'CHANGES_REQUESTED':
        baseColor = const Color(0xffEF4444);
        icon = Icons.error_outline_rounded;
        title =
            status == 'REJECTED' ? "Application Rejected" : "Changes Required";
        gradient = [const Color(0xffEF4444), const Color(0xffDC2626)];
        break;
      default:
        baseColor = const Color(0xff3B82F6);
        icon = Icons.pending_actions_rounded;
        title = "Under Review";
        gradient = [const Color(0xff3B82F6), const Color(0xff2563EB)];
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(icon, color: Colors.white.withOpacity(0.15), size: 120),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: CustomFonts.poppins,
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getStatusMessage(status),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (needsChanges && onEdit != null) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: baseColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      "Update Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'APPROVED':
        return "Your application has been verified. You can now proceed to final membership activation.";
      case 'REJECTED':
        return "Your application was not approved. Please review the remarks below for details.";
      case 'CHANGES_REQUESTED':
        return "Some details in your application need correction. Please update them and resubmit.";
      default:
        return "Our enrollment team is currently reviewing your profile and documents. We'll notify you soon.";
    }
  }
}

class TopStatusLabel extends StatelessWidget {
  final String status;

  const TopStatusLabel({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color =
        status == 'APPROVED'
            ? Colors.green
            : (status == 'REJECTED' ? Colors.red : Colors.blue);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            "CURRENT STATUS: $status",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
