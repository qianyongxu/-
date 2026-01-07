import 'dart:async';
import 'package:fluwx/fluwx.dart';
import 'package:flutter/foundation.dart';

class WeChatService {
  static const String appId = 'wx7d9cb886ea434628';
  static const String universalLink = 'https://hk.xbjy123.com/wechat/';

  final Fluwx _fluwx = Fluwx();
  final StreamController<WeChatAuthResponse> _authResponseController =
      StreamController.broadcast();

  WeChatService() {
    _fluwx.addSubscriber((response) {
      if (response is WeChatAuthResponse) {
        _authResponseController.add(response);
      }
    });
  }

  Future<void> init() async {
    await _fluwx.registerApi(appId: appId, universalLink: universalLink);
    debugPrint('WeChat SDK Initialized');
  }

  Future<bool> isInstalled() async {
    return await _fluwx.isWeChatInstalled;
  }

  Future<void> login() async {
    debugPrint('WeChat Login Initiated');
    final installed = await isInstalled();
    if (!installed) {
      debugPrint('WeChat not installed');
      throw Exception('未安装微信');
    }

    await _fluwx.authBy(
      which: NormalAuth(
        scope: 'snsapi_userinfo',
        state: 'hk_app_login_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  Future<void> shareWebPage({
    required String url,
    required String title,
    String? description,
    String? thumbnailUrl,
  }) async {
    final installed = await isInstalled();
    if (!installed) {
      throw Exception('未安装微信');
    }

    await _fluwx.share(
      WeChatShareWebPageModel(
        url,
        title: title,
        description: description,
        thumbnail: thumbnailUrl != null
            ? WeChatImage.network(thumbnailUrl)
            : null,
        scene: WeChatScene.session,
      ),
    );
  }

  // Listen to Auth Response
  Stream<WeChatAuthResponse> get authResponseStream =>
      _authResponseController.stream;
}
