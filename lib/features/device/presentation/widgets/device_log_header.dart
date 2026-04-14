import 'package:flutter/material.dart';

import '../theme/device_palette.dart';

class DeviceLogHeader extends StatelessWidget {
  const DeviceLogHeader({
    super.key,
    required this.logCount,
    required this.onClear,
    this.onRead,
    this.isConnected = false,
  });

  final int logCount;
  final VoidCallback onClear;

  /// 主动读取设备当前值的回调（仅连接状态下显示）
  final VoidCallback? onRead;
  final bool isConnected;

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
          // 已连接时显示「读取」按钮，主动拉取设备当前特征值
          if (isConnected && onRead != null) ...[
            GestureDetector(
              onTap: onRead,
              child: const Text(
                '读取',
                style: TextStyle(color: DevicePalette.gold, fontSize: 13),
              ),
            ),
            if (logCount > 0) const SizedBox(width: 16),
          ],
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
