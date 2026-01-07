import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../models/material_model.dart';
import '../models/app_models.dart';
import 'home_feed_screen.dart';
import 'category_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

import '../providers/locale_provider.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final _apiService = ApiService();

  final List<String> _navTitles = ['首页', '分类', '我的'];
  final List<IconData> _navIcons = [
    CupertinoIcons.house_fill,
    CupertinoIcons.square_grid_2x2_fill,
    CupertinoIcons.person_fill,
  ];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [HomeFeedScreen(), CategoryScreen(), ProfileScreen()];
    _checkConsecutiveDays();
    _checkMarketingPopup();
  }

  Future<void> _checkMarketingPopup() async {
    final popup = await _apiService.getActivePopup();
    if (popup == null) return;

    final prefs = await SharedPreferences.getInstance();
    final lastShowKey = 'popup_last_show_${popup.id}';
    final lastShowStr = prefs.getString(lastShowKey);

    bool shouldShow = false;
    if (popup.frequency == 'always') {
      shouldShow = true;
    } else if (popup.frequency == 'daily') {
      final today = DateTime.now().toString().split(' ')[0];
      if (lastShowStr != today) shouldShow = true;
    } else if (popup.frequency == 'once') {
      if (lastShowStr == null) shouldShow = true;
    }

    if (shouldShow) {
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) _showMarketingDialog(popup);
        final today = DateTime.now().toString().split(' ')[0];
        prefs.setString(lastShowKey, today);
      });
    }
  }

  void _showMarketingDialog(MarketingPopup popup) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  if (popup.targetUrl.isNotEmpty) {
                    launchUrl(
                      Uri.parse(popup.targetUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8 * 1.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(popup.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.xmark,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkConsecutiveDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRated = prefs.getBool('has_rated') ?? false;
      if (hasRated) return;

      final lastOpenStr = prefs.getString('last_open_date');
      final today = DateTime.now();
      final todayStr = "${today.year}-${today.month}-${today.day}";

      // First time
      if (lastOpenStr == null) {
        await prefs.setString('last_open_date', todayStr);
        await prefs.setInt('consecutive_days', 1);
        return;
      }

      // If already opened today, do nothing
      if (lastOpenStr == todayStr) return;

      // Parse dates safely
      try {
        final parts = lastOpenStr.split('-');
        if (parts.length == 3) {
          final lastOpen = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          final todayDate = DateTime(today.year, today.month, today.day);
          final diff = todayDate.difference(lastOpen).inDays;

          if (diff == 1) {
            int days = (prefs.getInt('consecutive_days') ?? 1) + 1;
            await prefs.setInt('consecutive_days', days);
            if (days >= 2) {
              _showRatingDialog();
            }
          } else {
            // Reset
            await prefs.setInt('consecutive_days', 1);
          }
          await prefs.setString('last_open_date', todayStr);
        }
      } catch (e) {
        // Reset on error
        await prefs.setString('last_open_date', todayStr);
        await prefs.setInt('consecutive_days', 1);
      }
    } catch (e) {
      // ignore
    }
  }

  void _showRatingDialog() {
    // Reuse dialog logic or create utility. For now inline.
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context).translate('give_rating')),
        content: Text('如果您觉得 HK 设计资源不错，请给我们一个好评支持一下吧！'),
        actions: [
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context).translate('cancel')),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context).translate('confirm')),
            isDefaultAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('has_rated', true);

              final Uri url = Uri.parse(
                'https://apps.apple.com/app/idYOUR_APP_ID',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch locale changes to rebuild bottom nav items
    Provider.of<LocaleProvider>(context);

    // Update nav titles based on current locale
    final List<String> _navTitles = [
      AppLocalizations.of(context).translate('home'),
      AppLocalizations.of(context).translate('category'),
      AppLocalizations.of(context).translate('profile'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Ambient Background (The "Aurora" Effect)
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
          Positioned(
            top: 200,
            right: -50,
            child: _buildAmbientOrb(Color(0xFFAF52DE), 200),
          ),
          // Blur Mesh
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 2. Content
          IndexedStack(index: _selectedIndex, children: _pages),

          // Search Button (Only show on Home)
          if (_selectedIndex == 0)
            Positioned(
              top: 60,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => SearchScreen()),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 3. Floating Navigation Capsule (The "Island")
          Positioned(
            bottom: 10 + MediaQuery.of(context).padding.bottom,
            left: 20,
            right: 20,
            child: Center(child: _buildFloatingNavBar()),
          ),
        ],
      ),
    );
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

  Widget _buildFloatingNavBar() {
    // Update nav titles based on current locale locally in this method if needed,
    // but better to pass or use the one from build method if it was instance variable.
    // However, _navTitles was defined in build() scope in previous step, but List.generate uses instance variable _navTitles which is wrong now.
    // Wait, I defined _navTitles in build() but the usage below uses _navTitles which might refer to the class member if I didn't remove the class member.
    // I should check if I removed the class member.
    // Actually, I should use the local variable from build(), but build() returns Scaffold. _buildFloatingNavBar is a separate method.
    // So I need to pass titles to _buildFloatingNavBar or make it use context to get titles.

    // Let's redefine titles inside here or use AppLocalizations directly.
    final List<String> navTitles = [
      AppLocalizations.of(context).translate('home'),
      AppLocalizations.of(context).translate('category'),
      AppLocalizations.of(context).translate('profile'),
    ];

    double screenWidth = MediaQuery.of(context).size.width;
    double navWidth = screenWidth > 600
        ? 300
        : screenWidth - 80; // Limit width on tablet

    return ClipRRect(
      borderRadius: BorderRadius.circular(100), // Pill shape
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: navWidth,
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(navTitles.length, (index) {
              final isSelected = _selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOutExpo,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _navIcons[index],
                          color: isSelected
                              ? Colors.black
                              : Colors.white.withOpacity(0.5),
                          size: 20,
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              navTitles[index],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
