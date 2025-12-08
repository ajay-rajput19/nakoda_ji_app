import 'package:flutter/material.dart';
import 'package:nakoda_ji/backend/models/temple_vist_model.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

class TempleVisitCard extends StatelessWidget {
  final TempleVistModel visit; 

  const TempleVisitCard({
    super.key,
    required this.visit,   
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: visit.bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(width: 1, color: CustomColors.clrCradBg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                visit.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.clrHeading,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: visit.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  visit.status,
                  style: TextStyle(
                    fontSize: 13,
                    color: visit.statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _infoRow(icon: Icons.calendar_month_outlined, text: visit.date),
          _infoRow(icon: Icons.access_time, text: visit.time),
          _infoRow(icon: Icons.self_improvement, text: visit.description),
          _infoRow(icon: Icons.history, text: "Duration: ${visit.duration}"),
        ],
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: CustomColors.clrInputText),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: CustomColors.clrText),
          ),
        ],
      ),
    );
  }
}
