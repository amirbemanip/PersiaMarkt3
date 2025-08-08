// lib/features/home/presentation/widgets/section_divider.dart
import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  final String title;
  const SectionDivider({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: 0.5, color: Colors.grey.shade400)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
            ),
          ),
          Expanded(child: Divider(thickness: 0.5, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}