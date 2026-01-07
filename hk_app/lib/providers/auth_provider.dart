import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthProvider with ChangeNotifier {
  HKUser? _user;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  HKUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    // Check local storage for persisted user
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        _user = HKUser.fromJson(jsonDecode(userData));
        notifyListeners();
      } catch (e) {
        // Corrupt data
        await prefs.remove('user_data');
      }
    }
  }

  Future<void> refreshUser() async {
    final currentUser = _user;
    if (currentUser == null) return;
    try {
      final updatedUser = await _apiService.getUser(
        currentUser.id,
        token: currentUser.token,
      );

      // Preserve token if missing in response
      if (updatedUser.token == null && currentUser.token != null) {
        final userMap = updatedUser.toJson();
        userMap['token'] = currentUser.token;
        _user = HKUser.fromJson(userMap);
      } else {
        _user = updatedUser;
      }

      final prefs = await SharedPreferences.getInstance();
      if (_user != null) {
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh user: $e');
    }
  }

  Future<void> loginWithWeChatCode(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get Device Info
      final deviceInfoPlugin = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      Map<String, dynamic> deviceData = {};

      try {
        deviceData['appVersion'] = packageInfo.version;

        if (Platform.isAndroid) {
          final androidInfo = await deviceInfoPlugin.androidInfo;
          deviceData['model'] = '${androidInfo.brand} ${androidInfo.model}';
          deviceData['os'] = 'Android ${androidInfo.version.release}';
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfoPlugin.iosInfo;
          // Use machine name (e.g. iPhone13,2) for exact model, or name for user friendly name
          deviceData['model'] = '${iosInfo.utsname.machine} (${iosInfo.name})';
          deviceData['os'] = 'iOS ${iosInfo.systemVersion}';
        }
      } catch (e) {
        debugPrint('Failed to get device info: $e');
      }

      final user = await _apiService.loginWithWeChat(
        code,
        deviceInfo: deviceData,
      );
      _user = user;

      // Persist
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));

      notifyListeners();
    } catch (e) {
      debugPrint('Login failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }
}
