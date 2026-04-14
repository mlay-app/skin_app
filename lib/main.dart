import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 关闭 flutter_blue_plus 库的内部原生日志（onCharacteristicChanged 等噪音日志）
  FlutterBluePlus.setLogLevel(LogLevel.none, color: false);
  runApp(const SkinApp());
}
