import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.isScanning});

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          const Text(
            '美莱雅',
            style: TextStyle(
              color: HomePalette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isScanning ? HomePalette.gold : HomePalette.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Mlay',
            style: TextStyle(
              color: HomePalette.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
