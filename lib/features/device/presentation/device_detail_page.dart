import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/conversion/number_base_converter.dart';
import '../../../shared/services/bluetooth/ble_plus_manager.dart';
import 'models/device_log_entry.dart';
import 'theme/device_palette.dart';
import 'widgets/device_connect_button.dart';
import 'widgets/device_detail_app_bar.dart';
import 'widgets/device_info_card.dart';
import 'widgets/device_log_header.dart';
import 'widgets/device_usage_panel.dart';

class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({super.key, required this.scanResult});

  final ScanResult scanResult;

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final BleManager _ble = BleManager();

  bool _isConnected = false;
  bool _isConnecting = false;
  final List<DeviceLogEntry> _logs = [];

  BluetoothDevice get _device => widget.scanResult.device;

  String get _deviceName =>
      _device.platformName.isNotEmpty ? _device.platformName : '未知设备';

  @override
  void dispose() {
    if (_isConnected) {
      _ble.disconnectDevice(_device);
    }
    super.dispose();
  }

  /// 从原始字节数组中解析 bytes 12-27 的 4 个模式槽
  /// 每槽 4 字节：[0] 模式码，[1..3] 3字节大端次数（使用 hexStringToInt 转换）
  List<DeviceModeSlot> _parseModeSlots(List<int> data) {
    if (data.length < 28) return [];
    return List.generate(4, (i) {
      final offset = 12 + i * 4;
      final modeCode = data[offset];
      // 将 3 个字节拼接为 6 位 hex 字符串，再用 hexStringToInt 转为十进制
      final hexStr = data[offset + 1].toRadixString(16).padLeft(2, '0') +
          data[offset + 2].toRadixString(16).padLeft(2, '0') +
          data[offset + 3].toRadixString(16).padLeft(2, '0');
      final count = hexStringToInt(hexStr);
      return DeviceModeSlot(modeCode: modeCode, count: count);
    });
  }

  Future<void> _connect() async {
    setState(() => _isConnecting = true);

    await _ble.connectDevice(
      _device,
      (data) {
        if (!mounted || data == null) {
          return;
        }

        final hexList = dataWithIntArr(data);
        final hex = hexList.join(' ').toUpperCase();
        final dec = dataWithStrArr(hexList).join(', ');
        final modeSlots = _parseModeSlots(data);

        setState(() {
          _logs.insert(
            0,
            DeviceLogEntry(
              hex: hex,
              dec: dec,
              time: _nowStr(),
              modeSlots: modeSlots,
            ),
          );
          if (_logs.length > 200) {
            _logs.removeLast();
          }
        });
      },
      (connected) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isConnected = connected ?? false;
          _isConnecting = false;
        });
      },
    );
  }

  Future<void> _disconnect() async {
    await _ble.disconnectDevice(_device);

    if (mounted) {
      setState(() {
        _isConnected = false;
        _logs.clear();
      });
    }
  }

  String _nowStr() {
    final t = DateTime.now();
    final ms = (t.millisecond ~/ 10).toString().padLeft(2, '0');
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}.$ms';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: DevicePalette.bg,
        body: SafeArea(
          child: Column(
            children: [
              DeviceDetailAppBar(
                deviceName: _deviceName,
                onBack: () => context.pop(),
              ),
              DeviceInfoCard(
                deviceName: _deviceName,
                remoteId: _device.remoteId.str,
                rssi: widget.scanResult.rssi,
                isConnected: _isConnected,
                isConnecting: _isConnecting,
              ),
              const SizedBox(height: 16),
              DeviceLogHeader(
                logCount: _logs.length,
                onClear: () => setState(() => _logs.clear()),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: DeviceUsagePanel(logs: _logs, isConnected: _isConnected),
              ),
              DeviceConnectButton(
                isConnected: _isConnected,
                isConnecting: _isConnecting,
                onConnect: _connect,
                onDisconnect: _disconnect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
