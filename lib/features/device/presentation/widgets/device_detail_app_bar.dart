import 'package:flutter/material.dart';

import '../theme/device_palette.dart';

class DeviceDetailAppBar extends StatelessWidget {
  const DeviceDetailAppBar({
    super.key,
    required this.deviceName,
    required this.onBack,
  });

  final String deviceName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DevicePalette.card,
                border: Border.all(color: DevicePalette.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: DevicePalette.textSecondary,
                size: 16,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                deviceName,
                style: const TextStyle(
                  color: DevicePalette.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}
