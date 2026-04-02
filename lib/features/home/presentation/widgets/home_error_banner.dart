import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

class HomeErrorBanner extends StatelessWidget {
  const HomeErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: HomePalette.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HomePalette.red.withOpacity(0.28)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: HomePalette.red,
              size: 17,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: HomePalette.red, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
