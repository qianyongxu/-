import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
// import 'package:fluwx/fluwx.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../theme_provider.dart';
import '../services/wechat_service.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'help_guide_screen.dart';
import 'feedback_screen.dart';
import 'my_collections_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final WeChatService _weChatService = WeChatService();
  bool _isWeChatInstalled = false;

  @override
  void initState() {
    super.initState();
    _initWeChat();
    // Refresh user info when entering profile to get latest stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).refreshUser();
    });
  }

  Future<void> _initWeChat() async {
    // Check installation status
    final installed = await _weChatService.isInstalled();
    if (mounted) {
      setState(() {
        _isWeChatInstalled = installed;
      });
    }
  }

  void _handleLogin() {
    if (!_isWeChatInstalled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('wechat_not_installed'),
          ),
          action: SnackBarAction(
            label: AppLocalizations.of(context).translate('confirm'),
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  void _handleWeChatShare() async {
    // final fluwx = Fluwx();
    // bool isInstalled = await fluwx.isWeChatInstalled;
    // if (!isInstalled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).translate('wechat_not_installed'),
        ),
      ),
    );
    //   return;
    // }

    // var model = WeChatShareWebPageModel(
    //   'https://hk.xbjy123.com',
    //   title: AppLocalizations.of(context).translate('app_name'),
    //   description: AppLocalizations.of(context).translate('share_content'),
    //   scene: WeChatScene.session,
    // );

    // fluwx.share(model);
  }

  void _showLanguageDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.grey.shade900.withOpacity(0.8),
                        Colors.grey.shade900.withOpacity(0.6),
                      ]
                    : [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                      ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              children: [
                // Handle Bar
                Container(
                  margin: EdgeInsets.only(top: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    AppLocalizations.of(context).translate('language'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    physics: BouncingScrollPhysics(),
                    children: [
                      _buildSection(
                        context,
                        isDark,
                        children: [
                          _buildLanguageTile(
                            context,
                            '中文简体',
                            Locale('zh', 'CN'),
                            isDark,
                          ),
                          _buildLanguageTile(
                            context,
                            '繁體中文',
                            Locale('zh', 'TW'),
                            isDark,
                          ),
                          _buildLanguageTile(
                            context,
                            'English',
                            Locale('en', ''),
                            isDark,
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDark, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final widget = entry.value;
          return Column(
            children: [
              widget,
              if (index != children.length - 1)
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String name,
    Locale locale,
    bool isDark,
  ) {
    final currentLocale = Provider.of<LocaleProvider>(context).locale;
    final isSelected =
        currentLocale?.languageCode == locale.languageCode &&
        (locale.countryCode == null ||
            currentLocale?.countryCode == locale.countryCode);

    return GestureDetector(
      onTap: () {
        Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
        Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark_alt,
                color: Color(0xFF007AFF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        // Sticky Header with SliverAppBar
        SliverAppBar(
          backgroundColor: Colors.transparent,
          pinned: false,
          floating: true,
          expandedHeight: 60.0, // Reduced from 120
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(left: 24, bottom: 16),
          ),
          actions: [
            // Language Button
            GestureDetector(
              onTap: _showLanguageDialog,
              child: Container(
                margin: EdgeInsets.only(right: 12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.language, color: textColor, size: 24),
              ),
            ),
            // Settings Button
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SettingsDialog(),
                );
              },
              child: Container(
                margin: EdgeInsets.only(right: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.settings,
                  color: textColor,
                  size: 24,
                ),
              ),
            ),
          ],
        ),

        // Login Card
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverToBoxAdapter(
            child: _buildLoginCard(isDark, authProvider, l10n),
          ),
        ),

        // Spacer
        SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Menu Items
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (authProvider.isAuthenticated) ...[
                _buildMenuItem(
                  context,
                  icon: CupertinoIcons.heart_fill,
                  title: l10n.translate('my_collections'),
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => MyCollectionsScreen()),
                    );
                  },
                ),
                SizedBox(height: 16),
              ],
              _buildMenuItem(
                context,
                icon: CupertinoIcons.chat_bubble_2_fill,
                title: l10n.translate('share_friends'),
                color: Color(0xFF07C160),
                onTap: _handleWeChatShare,
              ),
              SizedBox(height: 16),
              _buildMenuItem(
                context,
                icon: CupertinoIcons.book_fill,
                title: l10n.translate('usage_tutorial'),
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => HelpGuideScreen()),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildMenuItem(
                context,
                icon: CupertinoIcons.envelope_fill,
                title: l10n.translate('feedback'),
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => FeedbackScreen()),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildMenuItem(
                context,
                icon: CupertinoIcons.hand_thumbsup_fill,
                title: l10n.translate('give_rating'),
                color: Colors.pink,
                onTap: () async {
                  // Replace with your app store URL
                  final Uri url = Uri.parse(
                    'https://apps.apple.com/app/idYOUR_APP_ID',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
            ]),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildLoginCard(
    bool isDark,
    AuthProvider authProvider,
    AppLocalizations l10n,
  ) {
    final user = authProvider.user;
    final isLoggedIn = authProvider.isAuthenticated;

    return GestureDetector(
      onTap: isLoggedIn ? null : _handleLogin,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white24,
              // Fixed: Ensure avatarUrl is valid, otherwise fallback to null (icon)
              backgroundImage:
                  isLoggedIn &&
                      (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                  ? NetworkImage(user!.avatarUrl!)
                  : null,
              child:
                  (!isLoggedIn ||
                      user?.avatarUrl == null ||
                      user!.avatarUrl!.isEmpty)
                  ? Icon(
                      CupertinoIcons.person_fill,
                      color: Colors.white,
                      size: 40,
                    )
                  : null,
            ),
          ),
          SizedBox(height: 12),
          Text(
            isLoggedIn
                ? (user?.nickname ?? l10n.translate('wechat_user'))
                : l10n.translate('login_register'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24, // Increased from 20
              fontWeight: FontWeight.w700, // Increased weight
              letterSpacing: 0.5,
            ),
          ),
          if (isLoggedIn && user?.id != null) ...[
            SizedBox(height: 8), // Increased spacing
            // Removed ID display as requested
          ],
          if (!isLoggedIn) ...[
            SizedBox(height: 4),
            Text(
              _isWeChatInstalled
                  ? l10n.translate('login_wechat')
                  : l10n.translate('wechat_not_installed'),
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // Reduced from 24
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(
                16, // Reduced from 20
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10), // Reduced from 12
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12), // Reduced from 16
                  ),
                  child: Icon(icon, color: color, size: 20), // Reduced from 24
                ),
                SizedBox(width: 16), // Reduced from 20
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15, // Reduced from 16
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: secondaryTextColor.withOpacity(0.3),
                      size: 18,
                    ), // Reduced size
              ],
            ),
          ),
        ),
      ),
    );
  }
}
