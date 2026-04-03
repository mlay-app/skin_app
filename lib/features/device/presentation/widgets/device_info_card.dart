import 'package:flutter/material.dart';

import '../theme/device_palette.dart';

class DeviceInfoCard extends StatelessWidget {
  const DeviceInfoCard({
    super.key,
    required this.deviceName,
    required this.remoteId,
    required this.rssi,
    required this.isConnected,
    required this.isConnecting,
  });

  final String deviceName;
  final String remoteId;
  final int rssi;
  final bool isConnected;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: DevicePalette.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isConnected
                ? DevicePalette.gold.withOpacity(0.4)
                : DevicePalette.border,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E2A26),
                border: Border.all(
                  color: isConnected
                      ? DevicePalette.gold.withOpacity(0.5)
                      : DevicePalette.border,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.bluetooth_rounded,
                color: isConnected
                    ? DevicePalette.gold
                    : DevicePalette.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: const TextStyle(
                      color: DevicePalette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remoteId,
                    style: const TextStyle(
                      color: DevicePalette.textSecondary,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnecting
                              ? DevicePalette.gold
                              : isConnected
                              ? DevicePalette.green
                              : DevicePalette.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnecting
                            ? '连接中...'
                            : isConnected
                            ? '已连接'
                            : '未连接',
                        style: TextStyle(
                          color: isConnected
                              ? DevicePalette.green
                              : DevicePalette.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'RSSI $rssi dBm',
                        style: const TextStyle(
                          color: DevicePalette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
