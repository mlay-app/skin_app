import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

class ScanBanner extends StatelessWidget {
  const ScanBanner({
    super.key,
    required this.isScanning,
    required this.pulseAnim,
  });

  final bool isScanning;
  final Animation<double> pulseAnim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: HomePalette.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isScanning
                ? HomePalette.gold.withOpacity(0.45)
                : HomePalette.border,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: pulseAnim,
              builder: (context, child) => Transform.scale(
                scale: isScanning ? pulseAnim.value : 1.0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isScanning
                        ? HomePalette.gold.withOpacity(0.14)
                        : HomePalette.border.withOpacity(0.4),
                  ),
                  child: Icon(
                    Icons.bluetooth_searching_rounded,
                    color: isScanning
                        ? HomePalette.gold
                        : HomePalette.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isScanning ? '正在搜索设备...' : '搜索已完成',
                    style: TextStyle(
                      color: isScanning
                          ? HomePalette.textPrimary
                          : HomePalette.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isScanning ? '下拉可刷新 · 5 秒后自动停止' : '下拉刷新重新搜索',
                    style: const TextStyle(
                      color: HomePalette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isScanning)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: HomePalette.gold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
