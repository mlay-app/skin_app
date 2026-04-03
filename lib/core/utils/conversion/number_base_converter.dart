import 'dart:convert';

/// 字符串 -> 十六进制字符串（UTF-8编码）
String hexStringFromString(String input) {
  final bytes = utf8.encode(input);
  final buffer = StringBuffer();
  for (final b in bytes) {
    buffer.write(b.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

/// 十六进制字符串 -> 字符串（按UTF-8解码）
String stringFromHexString(String hex) {
  final bytes = dataWithHexString(hex);
  return utf8.decode(bytes);
}

/// 十六进制字符串 -> 十进制整数
int hexStringToInt(String hex) {
  return int.parse(hex, radix: 16);
}

/// 十进制整数 -> 十六进制字符串（不带0x前缀）
String intToHex(int num) {
  return num.toRadixString(16);
}

/// 十六进制字符串 -> int数组（每2位十六进制转1个字节）
List<int> dataWithHexString(String hex) {
  if (hex.length.isOdd) {
    throw const FormatException('Hex string length must be even');
  }

  final data = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    final pair = hex.substring(i, i + 2);
    data.add(hexStringToInt(pair));
  }
  return data;
}

/// int数组 -> 十六进制字符串数组（每个int转2位hex字符串）
List<String> dataWithIntArr(List<int> value) {
  final data = <String>[];
  for (final item in value) {
    data.add(item.toRadixString(16).padLeft(2, '0'));
  }
  return data;
}

/// 十六进制字符串数组 -> int数组
List<int> dataWithStrArr(List<String> value) {
  final data = <int>[];
  for (final item in value) {
    data.add(hexStringToInt(item));
  }
  return data;
}

/// 十六进制字符串 -> 十进制整数（兼容有/无0x前缀，失败返回null）
int? hex16ToInt2(String hex) {
  final normalized = hex.toUpperCase().startsWith('0X') ? hex : '0x$hex';
  return int.tryParse(normalized);
}
