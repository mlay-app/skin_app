import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = '等待操作';

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    setState(() {
      _status = statuses.entries
          .map((entry) => '${entry.key}: ${entry.value.name}')
          .join('\n');
    });
  }

  Future<void> _readAdapterState() async {
    final state = await FlutterBluePlus.adapterState.first;
    if (!mounted) return;
    setState(() {
      _status = '蓝牙状态: $state';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('脱毛仪测试 App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '首页模块: lib/features/home/presentation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _requestPermissions,
              child: const Text('请求蓝牙/定位权限'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _readAdapterState,
              child: const Text('读取蓝牙适配器状态'),
            ),
            const SizedBox(height: 16),
            Text(_status, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
