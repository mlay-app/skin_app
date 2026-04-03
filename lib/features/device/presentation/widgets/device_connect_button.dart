import 'package:flutter/material.dart';

import '../theme/device_palette.dart';

class DeviceConnectButton extends StatelessWidget {
  const DeviceConnectButton({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    required this.onConnect,
    required this.onDisconnect,
  });

  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final isDestructive = isConnected;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isConnecting
              ? null
              : (isDestructive ? onDisconnect : onConnect),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive
                ? DevicePalette.red.withOpacity(0.85)
                : DevicePalette.gold,
            foregroundColor: const Color(0xFF1A1614),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            elevation: 0,
            disabledBackgroundColor:
                (isDestructive ? DevicePalette.red : DevicePalette.gold)
                    .withOpacity(0.4),
            disabledForegroundColor: const Color(0xFF1A1614).withOpacity(0.6),
          ),
          child: isConnecting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF1A1614),
                  ),
                )
              : Text(
                  isDestructive ? '断开连接' : '连接设备',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
