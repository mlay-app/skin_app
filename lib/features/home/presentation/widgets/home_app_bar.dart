import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.isScanning});

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Mlay',
            style: TextStyle(
              color: HomePalette.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isScanning
                        ? HomePalette.gold
                        : HomePalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(width: 52, height: 1),
          ),
        ],
      ),
    );
  }
}
