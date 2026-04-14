import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

import '../theme/home_palette.dart';

class HomeDeviceCard extends StatelessWidget {
  const HomeDeviceCard({super.key, required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final platformName = result.device.platformName.trim();
    final advName = result.advertisementData.advName.trim();
    final cachedAdvName = result.device.advName.trim();
    final name = platformName.isNotEmpty
        ? platformName
        : advName.isNotEmpty
        ? advName
        : cachedAdvName.isNotEmpty
        ? cachedAdvName
        : '未知设备';
    final mac = result.device.remoteId.str;
    final rssi = result.rssi;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/device', extra: result),
          borderRadius: BorderRadius.circular(16),
          splashColor: HomePalette.gold.withOpacity(0.08),
          highlightColor: HomePalette.gold.withOpacity(0.04),
          child: Ink(
            decoration: BoxDecoration(
              color: HomePalette.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HomePalette.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2E2A26),
                      border: Border.all(
                        color: HomePalette.gold.withOpacity(0.28),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.bluetooth_rounded,
                      color: HomePalette.gold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: HomePalette.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mac,
                          style: const TextStyle(
                            color: HomePalette.textSecondary,
                            fontSize: 11,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _RssiBar(rssi: rssi),
                      const SizedBox(height: 3),
                      Text(
                        '$rssi dBm',
                        style: const TextStyle(
                          color: HomePalette.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: HomePalette.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RssiBar extends StatelessWidget {
  const _RssiBar({required this.rssi});

  final int rssi;

  @override
  Widget build(BuildContext context) {
    final int bars = rssi > -60
        ? 4
        : rssi > -70
        ? 3
        : rssi > -80
        ? 2
        : 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final active = i < bars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Container(
            width: 4,
            height: 5.0 + i * 3.5,
            decoration: BoxDecoration(
              color: active ? HomePalette.gold : HomePalette.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
