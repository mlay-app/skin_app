import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key, required this.isScanning});

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HomePalette.card,
              border: Border.all(color: HomePalette.border, width: 1.5),
            ),
            child: const Icon(
              Icons.bluetooth_disabled_rounded,
              color: HomePalette.textSecondary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isScanning ? '搜索中，请稍候...' : '未发现附近设备',
            style: const TextStyle(
              color: HomePalette.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '添加一台设备，开始美之旅程',
            style: TextStyle(color: Color(0xFF5A5450), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
