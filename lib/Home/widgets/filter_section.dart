import 'package:flutter/material.dart';

/// Reusable bottom-sheet section with a small icon pill, title, and child.
class FilterSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Widget child;

  const FilterSection({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
