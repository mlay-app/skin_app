import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/services/bluetooth/ble_plus_manager.dart';

// ── 设计 Token（与首页保持一致）──────────────────────────────────
const Color _kBg = Color(0xFF1A1614);
const Color _kCard = Color(0xFF252120);
const Color _kCardDeep = Color(0xFF1D1B18);
const Color _kGold = Color(0xFFC9A96E);
const Color _kTextPrimary = Color(0xFFF0E9DE);
const Color _kTextSecondary = Color(0xFF8A8078);
const Color _kBorder = Color(0xFF3A3530);
const Color _kGreen = Color(0xFF5CB87A);
const Color _kRed = Color(0xFFE05A4E);

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

  // 原始 HEX 日志，最新在前
  final List<_DataEntry> _logs = [];

  BluetoothDevice get _device => widget.scanResult.device;

  String get _deviceName => _device.platformName.isNotEmpty
      ? _device.platformName
      : '未知设备';

  @override
  void dispose() {
    if (_isConnected) _ble.disconnectDevice(_device);
    super.dispose();
  }

  // ── 连接 ────────────────────────────────────────────────────
  Future<void> _connect() async {
    setState(() => _isConnecting = true);

    await _ble.connectDevice(
      _device,
      // 收到数据回调
      (data) {
        if (!mounted || data == null) return;
        final hex =
            data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
        final dec = data.join(', ');
        setState(() {
          _logs.insert(0, _DataEntry(hex: hex, dec: dec, time: _nowStr()));
          // 只保留最近 200 条
          if (_logs.length > 200) _logs.removeLast();
        });
      },
      // 连接状态回调
      (connected) {
        if (!mounted) return;
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

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _kBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildDeviceInfoCard(),
              const SizedBox(height: 16),
              _buildLogHeader(),
              const SizedBox(height: 8),
              Expanded(child: _buildLogPanel()),
              _buildConnectButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kCard,
                border: Border.all(color: _kBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _kTextSecondary,
                size: 16,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                _deviceName,
                style: const TextStyle(
                  color: _kTextPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 占位，使标题居中
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  // ── 设备信息卡片 ──────────────────────────────────────────────
  Widget _buildDeviceInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isConnected ? _kGold.withOpacity(0.4) : _kBorder,
          ),
        ),
        child: Row(
          children: [
            // 设备图标
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E2A26),
                border: Border.all(
                  color:
                      _isConnected ? _kGold.withOpacity(0.5) : _kBorder,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.bluetooth_rounded,
                color: _isConnected ? _kGold : _kTextSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _deviceName,
                    style: const TextStyle(
                      color: _kTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _device.remoteId.str,
                    style: const TextStyle(
                      color: _kTextSecondary,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // 连接状态指示灯
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isConnecting
                              ? _kGold
                              : _isConnected
                                  ? _kGreen
                                  : _kTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isConnecting
                            ? '连接中...'
                            : _isConnected
                                ? '已连接'
                                : '未连接',
                        style: TextStyle(
                          color: _isConnected ? _kGreen : _kTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'RSSI ${widget.scanResult.rssi} dBm',
                        style: const TextStyle(
                          color: _kTextSecondary,
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

  // ── 日志区域标题 ──────────────────────────────────────────────
  Widget _buildLogHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text(
            '数据日志',
            style: TextStyle(
              color: _kTextPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          if (_logs.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _kGold.withOpacity(0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_logs.length}',
                style: const TextStyle(
                  color: _kGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Spacer(),
          if (_logs.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _logs.clear()),
              child: const Text(
                '清空',
                style: TextStyle(color: _kGold, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  // ── 日志面板 ──────────────────────────────────────────────────
  Widget _buildLogPanel() {
    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terminal_rounded, color: _kBorder, size: 40),
            const SizedBox(height: 12),
            Text(
              _isConnected ? '等待设备数据...' : '连接设备后将在此显示原始数据',
              style:
                  const TextStyle(color: _kTextSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: _kCardDeep,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: _logs.length,
          separatorBuilder: (_, __) => const Divider(
            color: Color(0xFF2E2926),
            height: 1,
          ),
          itemBuilder: (ctx, i) {
            final entry = _logs[i];
            final isLatest = i == 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 时间戳
                  SizedBox(
                    width: 76,
                    child: Text(
                      entry.time,
                      style: const TextStyle(
                        color: _kTextSecondary,
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
                        // HEX 行
                        Text(
                          entry.hex,
                          style: TextStyle(
                            color: isLatest ? _kGold : _kTextPrimary,
                            fontSize: 12,
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                        ),
                        // DEC 行
                        Text(
                          entry.dec,
                          style: const TextStyle(
                            color: _kTextSecondary,
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

  // ── 连接/断开按钮 ─────────────────────────────────────────────
  Widget _buildConnectButton() {
    final isDestructive = _isConnected;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isConnecting
              ? null
              : (isDestructive ? _disconnect : _connect),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive
                ? _kRed.withOpacity(0.85)
                : _kGold,
            foregroundColor: const Color(0xFF1A1614),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            elevation: 0,
            disabledBackgroundColor:
                (isDestructive ? _kRed : _kGold).withOpacity(0.4),
            disabledForegroundColor:
                const Color(0xFF1A1614).withOpacity(0.6),
          ),
          child: _isConnecting
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

// ── 数据条目模型 ──────────────────────────────────────────────────

class _DataEntry {
  const _DataEntry({
    required this.hex,
    required this.dec,
    required this.time,
  });

  final String hex;
  final String dec;
  final String time;
}
