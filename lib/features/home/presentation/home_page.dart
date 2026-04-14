import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skin_app/core/utils/logger/app_logger.dart';

import 'theme/home_palette.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_customer_service_chip.dart';
import 'widgets/home_device_card.dart';
import 'widgets/home_error_banner.dart';
import 'widgets/home_hero_banner.dart';
import 'widgets/home_quick_actions.dart';
import 'widgets/home_section_header.dart';
import 'widgets/home_start_care_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, ScanResult> _deviceMap = {};
  final PageController _bannerCtrl = PageController(viewportFraction: 1.0);

  bool _isScanning = false;
  bool _hasPermission = false;
  String? _errorMsg;
  int _bannerIndex = 0;

  StreamSubscription<List<ScanResult>>? _resultSub;
  StreamSubscription<bool>? _isScanningSub;

  @override
  void initState() {
    super.initState();

    _isScanningSub = FlutterBluePlus.isScanning.listen((scanning) {
      if (!mounted) {
        return;
      }
      setState(() => _isScanning = scanning);
    });

    _initAndScan();
  }

  @override
  void dispose() {
    _resultSub?.cancel();
    _isScanningSub?.cancel();
    _bannerCtrl.dispose();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _initAndScan() async {
    final ready = await _ensureReadyForScan();
    if (!ready) {
      return;
    }

    // 进入首页后默认自动扫描 5 秒
    await _startScan();
  }

  Future<bool> _requestPermissions() async {
    // Android 12+ (API 31) 使用 BLUETOOTH_SCAN / BLUETOOTH_CONNECT，
    // 旧版用 Permission.bluetooth；iOS 统一用 Permission.bluetooth。
    final List<Permission> permissions = [];

    if (Platform.isAndroid) {
      permissions.addAll([
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.locationWhenInUse,
      ]);
    } else {
      permissions.addAll([Permission.bluetooth, Permission.locationWhenInUse]);
    }

    final statuses = await permissions.request();

    bool bluetoothGranted;
    if (Platform.isAndroid) {
      final scanGranted =
          statuses[Permission.bluetoothScan]?.isGranted ?? false;
      final connectGranted =
          statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      bluetoothGranted = scanGranted && connectGranted;

      LogD(
        'bluetoothScan=$scanGranted, '
        'bluetoothConnect=$connectGranted, '
        'location=${statuses[Permission.locationWhenInUse]}',
      );
    } else {
      bluetoothGranted = statuses[Permission.bluetooth]?.isGranted ?? false;
    }

    final bool locationGranted =
        statuses[Permission.locationWhenInUse]?.isGranted ?? false;
    final bool granted = bluetoothGranted && locationGranted;

    if (mounted) {
      setState(() {
        _hasPermission = granted;
        if (!granted) {
          _errorMsg = '需要蓝牙和位置权限才能搜索设备';
        } else {
          _errorMsg = null;
        }
      });
    }

    LogI(
      '权限结果: granted=$granted '
      '(bluetooth=$bluetoothGranted, location=$locationGranted)',
    );
    return granted;
  }

  Future<bool> _ensureReadyForScan() async {
    final granted = await _requestPermissions();
    if (!granted) {
      return false;
    }

    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      if (mounted) {
        setState(() => _errorMsg = '请先开启手机蓝牙后重试');
      }
      return false;
    }

    return true;
  }

  Future<void> _startScan() async {
    if (_isScanning) {
      await FlutterBluePlus.stopScan();
      // 等待底层扫描完全停止，避免竞态
      await Future.delayed(const Duration(milliseconds: 300));
    }
    await _resultSub?.cancel();

    if (mounted) {
      setState(() {
        _deviceMap.clear();
        _errorMsg = null;
      });
    }

    LogI('开始扫描…');

    // flutter_blue_plus ^2.x 使用 scanResults（cumulative，每次回调含全量结果）
    _resultSub = FlutterBluePlus.scanResults.listen(
      (results) {
        if (!mounted) return;

        setState(() {
          for (final result in results) {
            final name = _resolvedDeviceName(result);
            final id = result.device.remoteId.str;
            LogD('发现设备: name="$name", id=$id, rssi=${result.rssi}');
            if (_isTargetDevice(result)) {
              _deviceMap[id] = result;
            }
          }
        });
      },
      onError: (Object e) {
        LogE('scanResults error: $e');
      },
    );

    // timeout 到期后 flutter_blue_plus 会自动 stopScan
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

    LogI('扫描完成，共发现 ${_deviceMap.length} 台目标设备');
  }

  Future<void> _onRefresh() async {
    final ready = await _ensureReadyForScan();
    if (ready) {
      await _startScan();
    }

    await Future.delayed(const Duration(milliseconds: 8500));
  }

  Future<void> _onAddDeviceTap() async {
    final ready = await _ensureReadyForScan();
    if (!ready) {
      return;
    }
    await _startScan();
  }

  void _onQuickActionTap(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title 功能即将上线'),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  String _scanStatusText() {
    if (!_hasPermission) {
      return '请先授权蓝牙和定位权限';
    }
    if (_isScanning) {
      return '正在搜索设备（8 秒自动停止）';
    }
    if (_devices.isEmpty) {
      return '未发现可用设备，可再次点击添加设备';
    }
    return '已完成扫描，点击设备即可进入连接';
  }

  List<ScanResult> get _devices =>
      _deviceMap.values.toList()..sort((a, b) => b.rssi.compareTo(a.rssi));

  String _resolvedDeviceName(ScanResult result) {
    final platformName = result.device.platformName.trim();
    if (platformName.isNotEmpty) {
      return platformName;
    }

    final advName = result.advertisementData.advName.trim();
    if (advName.isNotEmpty) {
      return advName;
    }

    final cachedAdvName = result.device.advName.trim();
    return cachedAdvName;
  }

  bool _isTargetDevice(ScanResult result) {
    final name = _resolvedDeviceName(result).toUpperCase();
    return name.startsWith('D21');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: HomePalette.bg,
        body: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                color: HomePalette.gold,
                backgroundColor: HomePalette.card,
                displacement: 18,
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: HomeAppBar(isScanning: _isScanning),
                    ),
                    SliverToBoxAdapter(
                      child: HomeHeroBanner(
                        pageController: _bannerCtrl,
                        currentIndex: _bannerIndex,
                        onPageChanged: (index) {
                          if (!mounted) {
                            return;
                          }
                          setState(() => _bannerIndex = index);
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: HomeQuickActions(onTap: _onQuickActionTap),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(14, 14, 14, 2),
                        child: Text(
                          '开始护理',
                          style: TextStyle(
                            color: HomePalette.textPrimary,
                            fontSize: 34 * 0.82,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: HomeStartCareCard(
                        isScanning: _isScanning,
                        deviceCount: _devices.length,
                        statusText: _scanStatusText(),
                        onAddTap: _onAddDeviceTap,
                      ),
                    ),
                    if (_errorMsg != null)
                      SliverToBoxAdapter(
                        child: HomeErrorBanner(message: _errorMsg!),
                      ),
                    if (_devices.isNotEmpty)
                      SliverToBoxAdapter(
                        child: HomeSectionHeader(
                          title: '可连接设备',
                          subtitle: '仅显示蓝牙名以 DC 开头的设备',
                          count: _devices.length,
                        ),
                      ),
                    if (_devices.isNotEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              HomeDeviceCard(result: _devices[index]),
                          childCount: _devices.length,
                        ),
                      ),
                    if (_devices.isEmpty && !_isScanning)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(14, 10, 14, 0),
                          child: Text(
                            '下拉可重新扫描，或点击“添加设备”开始搜索',
                            style: TextStyle(
                              color: HomePalette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 128)),
                  ],
                ),
              ),
              Positioned(
                right: 14,
                bottom: 26,
                child: HomeCustomerServiceChip(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('客服通道开发中'),
                        duration: Duration(milliseconds: 1200),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
