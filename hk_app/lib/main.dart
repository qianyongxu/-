import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart'; 
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

import 'services/analytics_service.dart';
import 'services/wechat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  debugPrint('HK_APP_START: Main started');

  runApp(const HKApp());
}

class HKApp extends StatelessWidget {
  const HKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: '绘库设计资源',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Color(0xFFF2F2F7),
        primaryColor: Colors.black,
        colorScheme: ColorScheme.light(
          primary: Colors.black,
          secondary: Color(0xFF007AFF),
          surface: Colors.white,
          background: Color(0xFFF2F2F7),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontFamily: '.SF Pro Display',
            letterSpacing: -1,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(fontFamily: '.SF Pro Text', color: Colors.black),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: SharedAxisPageTransitionsBuilder(
              transitionType: SharedAxisTransitionType.horizontal,
            ),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.white,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF64D2FF),
          surface: Color(0xFF1C1C1E),
          background: Colors.black,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontFamily: '.SF Pro Display',
            letterSpacing: -1,
          ),
          bodyLarge: TextStyle(fontFamily: '.SF Pro Text'),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: SharedAxisPageTransitionsBuilder(
              transitionType: SharedAxisTransitionType.horizontal,
            ),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const _AuthCheckWrapper(),
    );
  }
}

class _AuthCheckWrapper extends StatefulWidget {
  const _AuthCheckWrapper();
  @override
  State<_AuthCheckWrapper> createState() => _AuthCheckWrapperState();
}

class _AuthCheckWrapperState extends State<_AuthCheckWrapper> {
  @override
  void initState() {
    super.initState();
    WeChatService().init().catchError((e) => debugPrint('WX Init Error: $e'));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Provider.of<AuthProvider>(context, listen: false).tryAutoLogin(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Scaffold(backgroundColor: Colors.black);
        }
        if (snapshot.data == true) {
           return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
