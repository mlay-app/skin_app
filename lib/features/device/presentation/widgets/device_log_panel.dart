import 'package:flutter/material.dart';

import '../models/device_log_entry.dart';
import '../theme/device_palette.dart';

class DeviceLogPanel extends StatelessWidget {
  const DeviceLogPanel({
    super.key,
    required this.logs,
    required this.isConnected,
  });

  final List<DeviceLogEntry> logs;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terminal_rounded, color: DevicePalette.border, size: 40),
            const SizedBox(height: 12),
            Text(
              isConnected ? '等待设备数据...' : '连接设备后将在此显示原始数据',
              style: const TextStyle(
                color: DevicePalette.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: DevicePalette.cardDeep,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DevicePalette.border),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: logs.length,
          separatorBuilder: (context, index) =>
              const Divider(color: Color(0xFF2E2926), height: 1),
          itemBuilder: (context, index) {
            final entry = logs[index];
            final isLatest = index == 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 76,
                    child: Text(
                      entry.time,
                      style: const TextStyle(
                        color: DevicePalette.textSecondary,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.hex,
                          style: TextStyle(
                            color: isLatest
                                ? DevicePalette.gold
                                : DevicePalette.textPrimary,
                            fontSize: 12,
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                        ),
                        Text(
                          entry.dec,
                          style: const TextStyle(
                            color: DevicePalette.textSecondary,
                            fontSize: 10,
                            fontFamily: 'monospace',
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
