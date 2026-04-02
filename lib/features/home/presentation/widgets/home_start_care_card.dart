import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

class HomeStartCareCard extends StatelessWidget {
  const HomeStartCareCard({
    super.key,
    required this.isScanning,
    required this.deviceCount,
    required this.statusText,
    required this.onAddTap,
  });

  final bool isScanning;
  final int deviceCount;
  final String statusText;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Container(
        decoration: BoxDecoration(
          color: HomePalette.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: HomePalette.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isScanning ? null : onAddTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomePalette.gold,
                  foregroundColor: const Color(0xFF1A1614),
                  disabledBackgroundColor: HomePalette.gold.withOpacity(0.5),
                  disabledForegroundColor: const Color(
                    0xFF1A1614,
                  ).withOpacity(0.7),
                  minimumSize: const Size(0, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isScanning ? '扫描中...' : '+ 添加设备',
                  style: const TextStyle(
                    fontSize: 32 * 0.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              deviceCount > 0
                  ? '已发现 $deviceCount 台设备，点击可开始连接'
                  : '添加一台设备，开始美之旅程',
              style: const TextStyle(
                color: HomePalette.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              statusText,
              style: const TextStyle(
                color: HomePalette.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
