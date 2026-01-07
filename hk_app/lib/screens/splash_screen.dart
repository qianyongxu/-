import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAgreed = prefs.getBool('has_agreed_privacy') ?? false;

    if (!hasAgreed) {
      // Show Privacy Dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPrivacyDialog(prefs);
      });
    } else {
      // Proceed normally
      _checkAuth();
    }
  }

  void _showPrivacyDialog(SharedPreferences prefs) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.shield_fill,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '服务协议与隐私政策',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '欢迎使用绘库设计App！\n\n请您在使用前仔细阅读并同意《服务协议》和《隐私政策》。我们将严格遵守相关法律法规，保护您的个人信息和隐私安全。\n\n我们将仅在您授权的范围内收集和使用您的信息，用于提供更好的服务。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 5,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => _WebPageScreen(
                            title: '服务协议',
                            url: 'https://hk.xbjy123.com/web/terms.html',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      '《服务协议》',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Text(
                    ' 和 ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => _WebPageScreen(
                            title: '隐私政策',
                            url: 'https://hk.xbjy123.com/web/privacy.html',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      '《隐私政策》',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        '不同意',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        // Show toast or shake
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(25),
                      child: Text(
                        '同意并继续',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await prefs.setBool('has_agreed_privacy', true);
                        await _requestPermissions();
                        _checkAuth();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    // Request permissions sequentially

    // 1. Network (Usually granted by default, but checking state is good)
    // No specific permission request for internet on mobile usually, but we can check connectivity

    // 2. Location - REMOVED as per request (Use IP Geolocation instead)

    // 3. Storage / Photos (AddOnly for saving)
    if (await Permission.photosAddOnly.status.isDenied) {
      await Permission.photosAddOnly.request();
    }

    // 4. Notification
    await Permission.notification.request();

    // 5. Tracking (IDFA)
    await Permission.appTrackingTransparency.request();
  }

  Future<void> _checkAuth() async {
    // Simulate splash delay
    await Future.delayed(Duration(seconds: 2));

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.init();

      if (mounted) {
        if (authProvider.isAuthenticated) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (_) => MainScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (_) => LoginScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in splash auth check: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a transparent background or match the LaunchScreen
    return Scaffold(
      backgroundColor: Colors.white, // Match native launch screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo or splash content
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebPageScreen extends StatefulWidget {
  final String title;
  final String url;

  const _WebPageScreen({required this.title, required this.url});

  @override
  State<_WebPageScreen> createState() => _WebPageScreenState();
}

class _WebPageScreenState extends State<_WebPageScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('完成'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) Center(child: CupertinoActivityIndicator()),
          ],
        ),
      ),
    );
  }
}
