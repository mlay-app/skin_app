import 'package:flutter/material.dart';

import '../models/device_log_entry.dart';
import '../theme/device_palette.dart';

/// 使用记录面板 —— 仿时间轴卡片风格（参照图二）
/// 每条记录展示接收时间 + 4 个模式槽（模式名称 + 发射次数）
class DeviceUsagePanel extends StatelessWidget {
  const DeviceUsagePanel({
    super.key,
    required this.logs,
    required this.isConnected,
  });

  final List<DeviceLogEntry> logs;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return _EmptyState(isConnected: isConnected);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return _TimelineItem(
          entry: logs[index],
          isFirst: index == 0,
          isLast: index == logs.length - 1,
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 时间轴条目
// ──────────────────────────────────────────────────────────────
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  final DeviceLogEntry entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 时间轴竖线 + 节点圆点 ──
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // 顶部连接线（非第一条才显示）
                Container(
                  width: 1,
                  height: isFirst ? 16 : 12,
                  color: isFirst ? Colors.transparent : DevicePalette.border,
                ),
                // 节点圆点
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isFirst ? DevicePalette.gold : DevicePalette.border,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFirst
                          ? DevicePalette.gold.withValues(alpha: 0.4)
                          : DevicePalette.border,
                      width: 2,
                    ),
                  ),
                ),
                // 底部连接线（非最后一条才显示）
                if (!isLast)
                  Expanded(
                    child: Container(width: 1, color: DevicePalette.border),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── 内容区域 ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  // 时间戳
                  _TimeBadge(time: entry.time, isLatest: isFirst),
                  const SizedBox(height: 10),
                  // 模式卡片
                  if (entry.modeSlots.isNotEmpty)
                    _ModeCard(slots: entry.modeSlots, isLatest: isFirst)
                  else
                    _RawDataChip(hex: entry.hex),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 时间戳 Badge
// ──────────────────────────────────────────────────────────────
class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.time, required this.isLatest});

  final String time;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    // time 格式: HH:MM:SS.ms (e.g. "14:23:45.12")
    final parts = time.split(':');
    final hourMin = parts.length >= 2 ? '${parts[0]}:${parts[1]}' : time;
    final secMs = parts.length >= 3 ? ':${parts[2]}' : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          hourMin,
          style: TextStyle(
            color: isLatest ? DevicePalette.textPrimary : DevicePalette.textSecondary,
            fontSize: isLatest ? 22 : 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          secMs,
          style: TextStyle(
            color: DevicePalette.textSecondary,
            fontSize: isLatest ? 13 : 11,
            fontWeight: FontWeight.w400,
            fontFamily: 'monospace',
          ),
        ),
        if (isLatest) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: DevicePalette.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '最新',
              style: TextStyle(
                color: DevicePalette.gold,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 4 模式槽卡片
// ──────────────────────────────────────────────────────────────
class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.slots, required this.isLatest});

  final List<DeviceModeSlot> slots;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLatest ? DevicePalette.card : DevicePalette.cardDeep,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatest
              ? DevicePalette.gold.withValues(alpha: 0.22)
              : DevicePalette.border,
        ),
      ),
      child: Column(
        children: [
          // 卡片头部
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: DevicePalette.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '模式记录',
                  style: TextStyle(
                    color: DevicePalette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // 显示有效模式数量
                Text(
                  '${slots.where((s) => s.hasData).length} / ${slots.length} 活跃',
                  style: const TextStyle(
                    color: DevicePalette.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2E2926), height: 1),
          // 模式行列表
          ...slots.asMap().entries.map((e) {
            final isLastSlot = e.key == slots.length - 1;
            return _ModeRow(
              slot: e.value,
              slotIndex: e.key,
              showDivider: !isLastSlot,
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 单个模式行
// ──────────────────────────────────────────────────────────────
class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.slot,
    required this.slotIndex,
    required this.showDivider,
  });

  final DeviceModeSlot slot;
  final int slotIndex;
  final bool showDivider;

  /// 不同槽位对应的指示色
  static const List<Color> _slotColors = [
    DevicePalette.gold,
    Color(0xFF7EC8A0),  // 青绿
    Color(0xFF7BAED4),  // 淡蓝
    Color(0xFFCA8A8A),  // 玫瑰
  ];

  Color get _indicatorColor => slot.hasData
      ? _slotColors[slotIndex % _slotColors.length]
      : DevicePalette.border;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // 指示线（仿图二中的 ─── 前缀）
              Container(
                width: 18,
                height: 2,
                decoration: BoxDecoration(
                  color: _indicatorColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 10),
              // 模式名称
              Expanded(
                child: Text(
                  slot.modeName,
                  style: TextStyle(
                    color: slot.hasData
                        ? DevicePalette.textPrimary
                        : DevicePalette.textSecondary,
                    fontSize: 13,
                    fontWeight:
                        slot.hasData ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              // 次数（十进制）
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    slot.formattedCount,
                    style: TextStyle(
                      color: slot.hasData
                          ? _slotColors[slotIndex % _slotColors.length]
                          : DevicePalette.textSecondary,
                      fontSize: slot.hasData ? 16 : 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '发',
                    style: TextStyle(
                      color: slot.hasData
                          ? DevicePalette.textSecondary
                          : DevicePalette.border,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            color: Color(0xFF2A2724),
            height: 1,
            indent: 14,
            endIndent: 14,
          ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 原始数据 Chip（数据包太短时的降级显示）
// ──────────────────────────────────────────────────────────────
class _RawDataChip extends StatelessWidget {
  const _RawDataChip({required this.hex});

  final String hex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DevicePalette.cardDeep,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DevicePalette.border),
      ),
      child: Text(
        hex,
        style: const TextStyle(
          color: DevicePalette.textSecondary,
          fontSize: 11,
          fontFamily: 'monospace',
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 空状态
// ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DevicePalette.card,
              shape: BoxShape.circle,
              border: Border.all(color: DevicePalette.border),
            ),
            child: const Icon(
              Icons.timeline_rounded,
              color: DevicePalette.border,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isConnected ? '等待设备上报数据...' : '连接设备后显示使用记录',
            style: const TextStyle(
              color: DevicePalette.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
