import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  String? _deviceId;
  String? _deviceModel;
  String? _appVersion;
  
  Future<void> init() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor;
      _deviceModel = iosInfo.utsname.machine; // e.g. "iPhone13,4"
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id;
      _deviceModel = '${androidInfo.brand} ${androidInfo.model}';
    }
    
    // Log App Open
    logEvent('app_open');
  }

  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (_deviceId == null) return;

    try {
      final body = {
        'event': eventName,
        'deviceId': _deviceId,
        'deviceModel': _deviceModel,
        'appVersion': _appVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.operatingSystem,
        ...?parameters,
      };

      debugPrint('Analytics: $eventName - $body');

      await http.post(
        Uri.parse('${ApiService.baseUrl}/analytics/event'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      debugPrint('Failed to log analytics: $e');
    }
  }
}
