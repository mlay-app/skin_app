import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../core/utils/logger/app_logger.dart';

typedef ScanResultHandler = void Function(List<ScanResult>? datas);
typedef CharacteristicHandler = void Function(List<int>? datas);
typedef ConnectState = void Function(bool? isConnected);

class BleManager {
  BleManager._instance();

  factory BleManager() => _getInstance;
  static final BleManager _getInstance = BleManager._instance();

  BluetoothDevice? selectDevice;
  BluetoothCharacteristic? mCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic; // 单独保存通知特征，用于主动读取
  StreamSubscription<List<int>>? notifyStream;
  StreamSubscription<BluetoothConnectionState>? bleDeviceStream;
  StreamSubscription<List<ScanResult>>? scanResultStream;
  bool isConnected = false;
  bool _isDisconnecting = false; // 添加断开连接标志位
  DateTime? _bleConnectTime;
  int _currentMtu = 23; // 默认BLE MTU值
  static const String _serviceUuidPrimary = 'FFE0';
  static const String _notifyCharUuidPrimary = 'FFE1';
  static const String _writeCharUuidPrimary = 'FFE2';
  static const String _serviceUuidSecondary =
      '02F00000-0000-0000-0000-00000000FE00';
  static const String _notifyCharUuidSecondary =
      '02F00000-0000-0000-0000-00000000FF02';
  static const String _writeCharUuidSecondary =
      '02F00000-0000-0000-0000-00000000FF00';

  Future<void> cancelNotify() async {
    if (notifyStream != null) {
      LogD('msg cancelNotify');
      await notifyStream!.cancel();
      notifyStream = null;
    }
  }

  Future<void> characteristicToWriteValue(
    List<int> list, {
    bool withoutResponse = false,
  }) async {
    // 检查是否正在断开连接
    if (_isDisconnecting) {
      LogD('设备正在断开连接，跳过数据写入');
      return;
    }

    final BluetoothCharacteristic? characteristic = mCharacteristic;
    if (characteristic == null) {
      LogE('写入失败: 写特征未设置');
      return;
    }

    // 根据MTU计算最大数据包大小 (MTU - 3字节的ATT头部)
    int maxDataSize = _currentMtu - 3;
    if (maxDataSize <= 0) {
      maxDataSize = 20;
    }

    if (list.length > maxDataSize) {
      for (var i = 0; i < list.length; i += maxDataSize) {
        // 检查是否正在断开连接
        if (_isDisconnecting) {
          LogD('设备正在断开连接，停止数据写入');
          return;
        }

        var end = (i + maxDataSize < list.length)
            ? i + maxDataSize
            : list.length;
        var chunk = list.sublist(i, end);
        LogD('msg=write chunk=$chunk (size: ${chunk.length})');
        await characteristic.write(chunk, withoutResponse: withoutResponse);
      }
    } else {
      return await characteristic.write(list, withoutResponse: withoutResponse);
    }
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      LogD('开始断开蓝牙设备连接');
      _isDisconnecting = true; // 设置断开连接标志
      isConnected = false;

      if (bleDeviceStream != null) {
        await bleDeviceStream!.cancel();
        bleDeviceStream = null;
      }
      await cancelNotify();

      LogD('蓝牙监听器已清理');
      await device.disconnect();
      LogD('蓝牙设备已断开连接');
    } catch (e) {
      LogD('断开蓝牙连接时发生错误: $e');
    } finally {
      _isDisconnecting = false; // 重置标志位
      mCharacteristic = null;
      _notifyCharacteristic = null;
      selectDevice = null;
      _bleConnectTime = null;
      _currentMtu = 23;
    }
  }

  Future<void> connectDevice(
    BluetoothDevice device,
    CharacteristicHandler characteristicHandler,
    ConnectState state, {
    VoidCallback? onCharacteristicSet, // Make the parameter optional
  }) async {
    selectDevice = device;

    // 重置断开连接标志
    _isDisconnecting = false;

    if (isConnected) {
      LogD('msg=Already connected');
      state(true);
    } else {
      try {
        await device.connect(
          license: License.free,
          autoConnect: true,
          timeout: const Duration(seconds: 4),
          mtu: null,
        );
      } on Exception catch (e) {
        LogD("BlueTooth error to connect: $e");
        // Handle connection error
        state(false);
        return;
      }
    }

    await bleDeviceStream?.cancel();
    bleDeviceStream = selectDevice?.connectionState.listen((event) async {
      if (event == BluetoothConnectionState.disconnected) {
        LogD('msg=Disconnected');
        state(false);
        isConnected = false;
        mCharacteristic = null;
        await cancelNotify();
      } else if (event == BluetoothConnectionState.connected) {
        // 检查是否正在断开连接
        if (_isDisconnecting) {
          LogD('设备正在断开连接，跳过连接后的处理');
          return;
        }
        LogD('msg=Connected');
        _bleConnectTime = DateTime.now();
        isConnected = true;

        // 设置MTU为40
        try {
          int newMtu = await device.requestMtu(40);
          _currentMtu = newMtu;
          LogD('MTU设置成功: $newMtu');
        } catch (e) {
          LogD('MTU设置失败: $e, 使用默认值: $_currentMtu');
        }

        // 检查是否正在断开连接
        if (_isDisconnecting) {
          LogD('设备正在断开连接，跳过后续处理');
          return;
        }

        state(true);

        // 检查是否正在断开连接
        if (_isDisconnecting) {
          LogD('设备正在断开连接，跳过服务发现');
          return;
        }

        List<BluetoothService> services = await device.discoverServices();

        // 再次检查是否正在断开连接
        if (_isDisconnecting) {
          LogD('设备正在断开连接，跳过服务处理');
          return;
        }

        // 优先使用主服务（FFE0），找到后不再继续遍历备用服务
        bool primaryServiceFound = false;

        for (BluetoothService service in services) {
          if (_uuidMatches(service.uuid, _serviceUuidPrimary)) {
            primaryServiceFound = true;
            List<BluetoothCharacteristic> characteristics =
                service.characteristics;
            for (BluetoothCharacteristic characteristic in characteristics) {
              if (_uuidMatches(characteristic.uuid, _writeCharUuidPrimary)) {
                // 主写特征：FFE2
                mCharacteristic = characteristic;
              } else if (_uuidMatches(
                characteristic.uuid,
                _notifyCharUuidPrimary,
              )) {
                // 主通知特征：FFE1
                if (mCharacteristic == null &&
                    characteristic.properties.write) {
                  // 兼容某些固件只有FFE1可写的情况
                  mCharacteristic = characteristic;
                }
                if (characteristic.properties.notify) {
                  _notifyCharacteristic = characteristic;
                  await setCharacteristicNotify(
                    characteristic,
                    true,
                    characteristicHandler,
                  );
                }
              }
            }
            LogD('主服务 FFE0 已配置完成，跳过备用服务');
            break; // 主服务配置完成，不再处理备用服务
          }
        }

        // 主服务不存在时，回退到备用服务
        if (!primaryServiceFound) {
          LogD('未找到主服务 FFE0，尝试备用服务');
          for (BluetoothService service in services) {
            if (_uuidMatches(service.uuid, _serviceUuidSecondary)) {
              List<BluetoothCharacteristic> characteristics =
                  service.characteristics;
              for (var characteristic in characteristics) {
                LogD("msg=${characteristic.uuid.toString()}");
                if (_uuidMatches(
                  characteristic.uuid,
                  _writeCharUuidSecondary,
                )) {
                  // 备用写特征：...FF00
                  mCharacteristic = characteristic;
                  if (onCharacteristicSet != null) {
                    onCharacteristicSet();
                  }
                } else if (_uuidMatches(
                  characteristic.uuid,
                  _notifyCharUuidSecondary,
                )) {
                  // 备用通知特征：...FF02
                  if (characteristic.properties.notify) {
                    _notifyCharacteristic = characteristic;
                    await setCharacteristicNotify(
                      characteristic,
                      true,
                      characteristicHandler,
                    );
                  }
                }
              }
              break;
            }
          }
        }
      }
    });
  }

  /// 主动读取通知特征的当前值（支持 read 属性时使用）
  Future<void> readNotifyCharacteristic() async {
    if (_isDisconnecting) return;
    final c = _notifyCharacteristic;
    if (c == null) return;
    if (!c.properties.read) {
      LogD('通知特征不支持 read，跳过主动读取');
      return;
    }
    try {
      final value = await c.read();
      LogD('主动读取通知特征值: $value');
    } catch (e) {
      LogD('主动读取特征值失败: $e');
    }
  }

  Future<void> setCharacteristicNotify(
    BluetoothCharacteristic c,
    bool notify,
    CharacteristicHandler characteristicHandler,
  ) async {
    // 检查是否正在断开连接
    if (_isDisconnecting) {
      LogD('设备正在断开连接，跳过特征值设置');
      return;
    }

    await cancelNotify();
    await c.setNotifyValue(notify);

    // 使用 onValueReceived 确保每一次设备推送都能触发，不会因值相同而被去重
    notifyStream = c.onValueReceived.listen((value) {
      if (value.isEmpty) {
        LogD('蓝牙返回数据为空，跳过');
        return;
      }

      // 过滤设备订阅握手响应，不作为业务数据处理
      final asString = String.fromCharCodes(value);
      if (asString == 'ntf_enable') {
        LogD('收到设备通知使能确认');
        return;
      }

      final hex = value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      LogD('特征值收到: [$hex]  (${value.length} bytes)');

      if (_bleConnectTime != null) {
        LogD(
          'msg=连接时间=${DateTime.now().difference(_bleConnectTime!).inSeconds}秒',
        );
        _bleConnectTime = null;
      }

      characteristicHandler(value);
    });
  }

  Future<void> startScan(
    ScanResultHandler dataHandler, {
    int timeout = 60,
  }) async {
    LogD("_scan");
    await scanResultStream?.cancel();
    scanResultStream = FlutterBluePlus.scanResults.listen((results) {
      dataHandler(results);
    });
    await FlutterBluePlus.startScan(
      timeout: Duration(seconds: timeout),
      withServices: [Guid(_serviceUuidPrimary)],
    );
  }

  Future<void> stopScan() async {
    LogD("_stopScan");
    await FlutterBluePlus.stopScan();
    await scanResultStream?.cancel();
    scanResultStream = null;
  }

  bool _uuidMatches(Guid uuid, String expected) {
    final String raw = uuid.toString().toUpperCase();
    final String target = expected.toUpperCase();
    if (raw == target) {
      return true;
    }
    if (target.length == 4) {
      if (_extractBluetoothBaseShort(raw) == target) {
        return true;
      }
      final String compact = raw.replaceAll('-', '');
      if (compact.endsWith(target)) {
        return true;
      }
    }
    return false;
  }

  String _extractBluetoothBaseShort(String rawUuid) {
    final String compact = rawUuid.replaceAll('-', '');
    final RegExp regExp = RegExp(
      r'^0000([0-9A-F]{4})00001000800000805F9B34FB$',
    );
    final RegExpMatch? match = regExp.firstMatch(compact);
    if (match != null) {
      return match.group(1) ?? '';
    }
    return '';
  }
}
