import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

class FixedStepIndicator extends StatelessWidget {
  final int currentStep;

  const FixedStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ["Personal Information", "Upload Documents", "Payment"];

    return Row(
      children: List.generate(steps.length, (index) {
        final bool isActive = index == currentStep;
        final bool isCompleted = index < currentStep;

        return Expanded(
          child: Row(
            children: [
              /// CIRCLE
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.blue
                      : isCompleted
                      ? CustomColors.clrBtnBg
                      : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              /// TITLE
              Expanded(
                child: Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 14,

                    overflow: TextOverflow.ellipsis,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? CustomColors.clrHeading
                        : CustomColors.clrText,
                  ),
                ),
              ),

              /// LINE except last step
              if (index != steps.length - 1)
                Container(width: 40, height: 2, color: Colors.grey.shade300),
            ],
          ),
        );
      }),
    );
  }
}
