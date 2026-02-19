import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:doin_fx/core/services/deviceServices/device_services.dart';
import 'package:doin_fx/setup.dart';

class DeviceServiceImplementation extends DeviceServices {

  bool _isPhysicalDevice = true;

  @override
  bool get isPhysicalDevice => _isPhysicalDevice;


  @override
  Future<void> findPhysicalDevice() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _isPhysicalDevice = androidInfo.isPhysicalDevice;
      baseUrl = _isPhysicalDevice ? 'http://192.168.1.7:5000/' : 'http://10.0.2.2:5000/';
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _isPhysicalDevice = iosInfo.isPhysicalDevice;
    }

    // default fallback
  }



}