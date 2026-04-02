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
  StreamSubscription<List<int>>? notifyStream;
  StreamSubscription<BluetoothConnectionState>? bleDeviceStream;
  StreamSubscription<List<ScanResult>>? scanResultStream;
  bool isConnected = false;
  bool _isDisconnecting = false; // 添加断开连接标志位
  DateTime? _bleConnectTime;
  int _currentMtu = 23; // 默认BLE MTU值

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

        for (BluetoothService service in services) {
          if (_uuidMatches(service.uuid, 'AE00')) {
            List<BluetoothCharacteristic> characteristics =
                service.characteristics;
            for (BluetoothCharacteristic characteristic in characteristics) {
              if (_uuidMatches(characteristic.uuid, 'AE01')) {
                //写数据
                mCharacteristic = characteristic;
              } else if (_uuidMatches(characteristic.uuid, 'AE02')) {
                //读数据
                if (characteristic.properties.notify) {
                  await setCharacteristicNotify(
                    characteristic,
                    true,
                    characteristicHandler,
                  );
                }
              }
            }
          } else if (_uuidMatches(service.uuid, '1000')) {
            List<BluetoothCharacteristic> characteristics =
                service.characteristics;
            for (var characteristic in characteristics) {
              LogD("msg=${characteristic.uuid.toString()}");
              if (_uuidMatches(characteristic.uuid, '1001')) {
                //写数据
                mCharacteristic = characteristic;
                if (onCharacteristicSet != null) {
                  onCharacteristicSet();
                }
                // values
              } else if (_uuidMatches(characteristic.uuid, '1002')) {
                //读数据
                if (characteristic.properties.notify) {
                  await setCharacteristicNotify(
                    characteristic,
                    true,
                    characteristicHandler,
                  );
                }
              }
            }
          }
        }
      }
    });
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
    notifyStream = c.onValueReceived.listen((value) {
      if (value.isEmpty) {
        LogD("我是蓝牙返回数据 - 空！！");
        return;
      }
      LogD('setCharacteristicNotify==$value');
      // List data = [];
      // for (var i = 0; i < value.length; i++) {
      //   String dataStr = value[i].toRadixString(16);
      //   if (dataStr.length < 2) {
      //     dataStr = "0" + dataStr;
      //   }
      //   data.add(dataStr);
      // }
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
      withServices: [Guid("1000")],
    );
  }

  Future<void> stopScan() async {
    LogD("_stopScan");
    await FlutterBluePlus.stopScan();
    await scanResultStream?.cancel();
    scanResultStream = null;
  }

  bool _uuidMatches(Guid uuid, String shortUuid) {
    return _extractShortUuid(uuid.toString()) == shortUuid.toUpperCase();
  }

  String _extractShortUuid(String rawUuid) {
    final String upper = rawUuid.toUpperCase();
    if (upper.length == 4) {
      return upper;
    }
    final String compact = upper.replaceAll('-', '');
    if (compact.length == 32) {
      return compact.substring(4, 8);
    }
    return upper;
  }
}
