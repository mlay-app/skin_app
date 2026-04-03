import 'package:flutter/material.dart';

import '../theme/device_palette.dart';

class DeviceLogHeader extends StatelessWidget {
  const DeviceLogHeader({
    super.key,
    required this.logCount,
    required this.onClear,
  });

  final int logCount;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text(
            '使用记录',
            style: TextStyle(
              color: DevicePalette.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          if (logCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: DevicePalette.gold.withOpacity(0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$logCount',
                style: const TextStyle(
                  color: DevicePalette.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Spacer(),
          if (logCount > 0)
            GestureDetector(
              onTap: onClear,
              child: const Text(
                '清空',
                style: TextStyle(color: DevicePalette.gold, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
