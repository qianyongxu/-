import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/wechat_service.dart';
import 'main_screen.dart';

import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimating = false;
  bool _agreedToTerms = false;
  final WeChatService _weChatService = WeChatService();

  @override
  void initState() {
    super.initState();
    // Initialize WeChat SDK
    _weChatService
        .init()
        .then((_) {
          debugPrint('WeChat SDK initialized in LoginScreen');
        })
        .catchError((e) {
          debugPrint('Failed to initialize WeChat SDK: $e');
        });

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isAnimating = true);
    });
  }

  void _handleLogin() async {
    if (!_agreedToTerms) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('提示'),
          content: Text('请先阅读并同意《服务协议》和《隐私政策》'),
          actions: [
            CupertinoDialogAction(
              child: Text('确定'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    debugPrint('_handleLogin called');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 1. Show loading
      debugPrint('Showing loading dialog');
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) =>
            Center(child: CupertinoActivityIndicator(color: Colors.white)),
      );

      // 2. Initiate WeChat Auth
      debugPrint('Calling _weChatService.login()');
      await _weChatService.login();
      debugPrint('_weChatService.login() returned');

      // 3. Listen for Response
      final response = await _weChatService.authResponseStream
          .firstWhere(
            (resp) => resp.errCode == 0,
            orElse: () => throw Exception('Auth cancelled or failed'),
          )
          .timeout(Duration(minutes: 2));

      if (response.errCode != 0) {
        throw Exception(
          'WeChat Auth Failed: ${response.errCode} ${response.errStr}',
        );
      }

      final code = response.code;
      if (code == null) {
        throw Exception('No auth code received');
      }

      // 4. Send Code to Backend
      await authProvider.loginWithWeChatCode(code);

      // 5. Close dialog
      if (mounted) Navigator.pop(context);

      // 6. Navigate to Main and Remove all previous routes
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (_) => MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close dialog if open
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Effects (Orbs)
          Positioned(
            top: -100,
            left: -100,
            child: _buildAmbientOrb(Color(0xFF007AFF), 300),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _buildAmbientOrb(Color(0xFFFF2D55), 300),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 2. Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),

                // Logo / Title
                AnimatedOpacity(
                  duration: Duration(milliseconds: 1000),
                  opacity: _isAnimating ? 1.0 : 0.0,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white24,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        '绘库设计',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '发现优质素材',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Spacer(),

                // Login Button
                AnimatedOpacity(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  opacity: _isAnimating ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _handleLogin,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Color(0xFF07C160), // WeChat Green
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF07C160).withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.chat_bubble_2_fill,
                                  color: Colors.white,
                                ), // Closest to WeChat
                                SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('login_wechat'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Terms and Privacy Checkbox
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreedToTerms = !_agreedToTerms;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(
                                  8,
                                ), // Increase touch area
                                child: Icon(
                                  _agreedToTerms
                                      ? CupertinoIcons.check_mark_circled_solid
                                      : CupertinoIcons.circle,
                                  color: _agreedToTerms
                                      ? Color(0xFF00C800)
                                      : Colors.grey,
                                  size: 24, // Increased size
                                ),
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: '我已阅读并同意',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14, // Increased size
                                ),
                                children: [
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        // Open Terms
                                        _openWebPage(
                                          context,
                                          '服务协议',
                                          'https://hk.xbjy123.com/web/terms.html',
                                        );
                                      },
                                      child: Text(
                                        '《服务协议》',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14, // Increased size
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(text: '和'),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        // Open Privacy
                                        _openWebPage(
                                          context,
                                          '隐私政策',
                                          'https://hk.xbjy123.com/web/privacy.html',
                                        );
                                      },
                                      child: Text(
                                        '《隐私政策》',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14, // Increased size
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openWebPage(BuildContext context, String title, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildAmbientOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.6),
      ),
    );
  }
}
