import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class SettingsDialog extends StatefulWidget {
  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
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
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
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
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  l10n.translate('settings'),
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
                      children: [
                        _buildListTile(
                          context,
                          title: l10n.translate('service_terms'),
                          icon: CupertinoIcons.doc_text,
                          onTap: () => _openWeb(
                            context,
                            l10n.translate('service_terms'),
                            'https://hk.xbjy123.com/web/terms.html',
                          ),
                        ),
                        _buildListTile(
                          context,
                          title: l10n.translate('privacy_policy'),
                          icon: CupertinoIcons.lock,
                          onTap: () => _openWeb(
                            context,
                            l10n.translate('privacy_policy'),
                            'https://hk.xbjy123.com/web/privacy.html',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildSection(
                      context,
                      children: [
                        _buildListTile(
                          context,
                          title: l10n.translate('version'),
                          icon: CupertinoIcons.info,
                          trailing: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'v$_version',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () {},
                        ),
                        _buildListTile(
                          context,
                          title: l10n.translate('contact_us'),
                          icon: CupertinoIcons.mail,
                          onTap: () async {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: 'support@hkdesign.com',
                            );
                            if (await canLaunchUrl(emailLaunchUri))
                              await launchUrl(emailLaunchUri);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    if (authProvider.isAuthenticated)
                      _buildSection(
                        context,
                        children: [
                          _buildListTile(
                            context,
                            title: l10n.translate('logout'),
                            icon: CupertinoIcons.power,
                            titleColor: Colors.red,
                            iconColor: Colors.red,
                            onTap: () {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: Text(l10n.translate('logout_confirm_title')),
                                  content: Text(l10n.translate('logout_confirm_content')),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: Text(l10n.translate('cancel')),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    CupertinoDialogAction(
                                      child: Text(l10n.translate('confirm')),
                                      isDestructiveAction: true,
                                      onPressed: () {
                                        authProvider.logout();
                                        Navigator.pop(context);
                                        Navigator.pop(context); // Close sheet
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
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
    );
  }

  Widget _buildSection(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
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
                  indent: 56,
                  endIndent: 16,
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color? titleColor,
    Color? iconColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = titleColor ?? (isDark ? Colors.white : Colors.black87);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? (isDark ? Colors.white : Colors.black)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? (isDark ? Colors.white : Colors.black87),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: themeColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
          ],
        ),
      ),
    );
  }

  void _openWeb(BuildContext context, String title, String url) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (_) => _WebPageScreen(title: title, url: url),
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
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.7),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(CupertinoIcons.xmark, color: isDark ? Colors.white : Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Container(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                  height: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: isDark ? Colors.black : Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoActivityIndicator(radius: 14),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
