import 'package:flutter/material.dart';

class InfoTooltip extends StatelessWidget {
  final String message;

  const InfoTooltip({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      child: Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
    );
  }
}
