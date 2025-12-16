import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor = const Color(0xFF2D6A4F),
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        final isCompleted = index < currentStep;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: isCompleted
                ? Container(
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }
}
