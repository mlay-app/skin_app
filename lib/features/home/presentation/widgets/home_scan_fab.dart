import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

class HomeScanFab extends StatelessWidget {
  const HomeScanFab({super.key, required this.isScanning, required this.onTap});

  final bool isScanning;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isScanning
                ? HomePalette.gold.withOpacity(0.45)
                : HomePalette.gold,
            foregroundColor: const Color(0xFF1A1614),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            elevation: 0,
            disabledBackgroundColor: HomePalette.gold.withOpacity(0.45),
            disabledForegroundColor: const Color(0xFF1A1614).withOpacity(0.7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isScanning ? Icons.radar_rounded : Icons.add_rounded,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isScanning ? '搜索中...' : ' 添加设备',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
