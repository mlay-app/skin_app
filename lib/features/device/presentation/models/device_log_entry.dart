/// 单个内存刀头模式数据槽（bytes 12-27 中每 4 字节一组）
class DeviceModeSlot {
  const DeviceModeSlot({required this.modeCode, required this.count});

  final int modeCode;

  /// 由 3 字节大端 hex 转换得到的十进制次数
  final int count;

  /// 协议定义模式名称映射（0x01 = 去痘模式）
  static const Map<int, String> _modeNames = {
    0x00: '未定义',
    0x01: '去痘模式',
    0x02: '嫩肤模式',
    0x03: '脱毛模式',
    0x04: '美白模式',
    0x05: '棕榈模式',
    0x06: '祛斑模式',
    0x07: '紧致模式',
    0x08: '修复模式',
    0x09: '嫩肤BX',
  };

  String get modeName =>
      _modeNames[modeCode] ??
      '模式 ${modeCode.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  /// 带千分位分隔的次数字符串
  String get formattedCount {
    if (count == 0) return '0';
    final s = count.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  /// 是否有效（有发射次数记录）
  bool get hasData => count > 0 && modeCode != 0x00;
}

class DeviceLogEntry {
  const DeviceLogEntry({
    required this.hex,
    required this.dec,
    required this.time,
    this.modeSlots = const [],
  });

  final String hex;
  final String dec;
  final String time;

  /// 从 bytes 12-27 解析出的 4 个模式槽，空列表表示数据包长度不足
  final List<DeviceModeSlot> modeSlots;
}
