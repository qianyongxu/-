import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/material_model.dart';
import '../models/app_models.dart';
import 'dart:ui';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
// import 'package:fluwx/fluwx.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/wechat_service.dart';
import '../l10n/app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialDetailScreen extends StatefulWidget {
  final MaterialModel material;

  const MaterialDetailScreen({required this.material});

  @override
  _MaterialDetailScreenState createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showTitleInAppBar = false;
  double _dragProgress =
      0.0; // 0.0 to 1.0 (1.0 means fully dragged down to dismiss)

  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isFavorite = false;
  final ApiService _apiService = ApiService();
  final WeChatService _weChatService = WeChatService();
  List<Software> _supportedSoftwareList = [];

  // Favorite Animation
  late AnimationController _favController;
  late Animation<double> _favScaleAnimation;

  @override
  void initState() {
    super.initState();
    _favController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _favScaleAnimation = TweenSequence(
      [
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 50),
      ],
    ).animate(CurvedAnimation(parent: _favController, curve: Curves.easeInOut));

    _checkFavorite();
    _fetchSoftwareList();
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showTitleInAppBar) {
        setState(() => _showTitleInAppBar = true);
      } else if (_scrollController.offset <= 300 && _showTitleInAppBar) {
        setState(() => _showTitleInAppBar = false);
      }
    });
  }

  Future<void> _fetchSoftwareList() async {
    final list = await _apiService.getSoftwareList();
    if (mounted) {
      setState(() {
        _supportedSoftwareList = list;
      });
    }
  }

  Future<void> _checkFavorite() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      try {
        final isFav = await _apiService.checkFavorite(
          widget.material.id,
          user.id,
        );
        if (mounted) setState(() => _isFavorite = isFav);
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('please_login_first'),
          ),
        ),
      );
      return;
    }

    // Store previous state for rollback
    final bool wasFavorite = _isFavorite;

    // Optimistic UI Update
    setState(() => _isFavorite = !_isFavorite);
    if (_isFavorite) {
      _favController.forward(from: 0.0);
    }

    try {
      final isFav = await _apiService.toggleFavorite(
        widget.material.id,
        user.id,
      );

      // Update with server truth
      if (mounted) {
        setState(() => _isFavorite = isFav);
        _showCustomToast(isFav ? '收藏成功' : '已取消收藏', isFav);
      }

      // Refresh user to update collection count
      if (mounted)
        Provider.of<AuthProvider>(context, listen: false).refreshUser();
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() => _isFavorite = wasFavorite);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }

  @override
  void dispose() {
    _favController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showCustomToast(String message, bool success) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: Duration(milliseconds: 200),
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        success
                            ? CupertinoIcons.check_mark_circled
                            : CupertinoIcons.xmark_circle,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        message,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    Future.delayed(Duration(seconds: 2), () => entry.remove());
  }

  void _handleWeChatShare() async {
    try {
      final isInstalled = await _weChatService.isInstalled();
      if (!isInstalled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).translate('wechat_not_installed'),
              ),
            ),
          );
        }
        return;
      }

      await _weChatService.shareWebPage(
        url:
            'https://hk.xbjy123.com/crm/web/material.html?id=${widget.material.id}',
        title: widget.material.title,
        description: '我在绘库发现了超棒的素材，还有更多抖音、小红书等画师同款素材、快来看看！',
        thumbnailUrl: widget.material.thumbnail,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    }
  }

  void _handleDownloadAndShare() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('please_login_first'),
          ),
        ),
      );
      return;
    }

    // Show loading
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(color: Colors.white, radius: 14),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).translate('checking_permission'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final apiService = ApiService();
      // This API call will verify VIP and daily limit
      await apiService.downloadMaterial(widget.material.id, user.id);

      // Update local user stats
      await Provider.of<AuthProvider>(context, listen: false).refreshUser();

      if (mounted) Navigator.pop(context); // Close "Checking permissions"

      // Proceed to download file
      if (mounted) {
        String? downloadUrl = widget.material.fileUrl;
        String? downloadName = widget.material.title;

        if ((downloadUrl == null || downloadUrl.isEmpty) &&
            widget.material.files.isNotEmpty) {
          downloadUrl = widget.material.files.first.url;
          downloadName = widget.material.files.first.name;
        }

        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          _startFileDownload(url: downloadUrl, name: downloadName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).translate('download_failed'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        String errorMsg = e.toString().replaceAll('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleFileDownload(MaterialFile file) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('please_login_first'),
          ),
        ),
      );
      return;
    }

    // Show loading
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(color: Colors.white, radius: 14),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).translate('checking_permission'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final apiService = ApiService();
      // Verify VIP and daily limit
      await apiService.downloadMaterial(widget.material.id, user.id);

      // Update local user stats
      await Provider.of<AuthProvider>(context, listen: false).refreshUser();

      if (mounted) Navigator.pop(context); // Close "Checking permissions"

      // Proceed to download file
      _startFileDownload(url: file.url, name: file.name);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        String errorMsg = e.toString().replaceAll('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _startFileDownload({String? url, String? name}) async {
    final downloadUrl = url ?? widget.material.fileUrl;
    final downloadName = name ?? widget.material.title;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      if (downloadUrl.isEmpty)
        throw Exception(
          AppLocalizations.of(context).translate('download_failed'),
        );

      final client = http.Client();
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception(
          '${AppLocalizations.of(context).translate('download_failed')}: ${response.statusCode}',
        );
      }

      final contentLength = response.contentLength ?? 0;
      List<int> bytes = [];
      int received = 0;

      await response.stream.listen((List<int> newBytes) {
        bytes.addAll(newBytes);
        received += newBytes.length;
        if (contentLength > 0) {
          setState(() {
            _downloadProgress = received / contentLength;
          });
        }
      }).asFuture();

      setState(() {
        _isDownloading = false;
        _downloadProgress = 1.0;
      });

      final tempDir = await getTemporaryDirectory();
      String fileName = downloadUrl.split('/').last;
      if (fileName.isEmpty || !fileName.contains('.')) {
        fileName = '${downloadName}_${DateTime.now().millisecondsSinceEpoch}';
      }

      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Trigger Rating Logic
      _checkAndShowRating();

      // Share in background to avoid blocking UI
      Future.delayed(Duration(milliseconds: 100), () async {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && mounted) {
          await Share.shareXFiles(
            [XFile(file.path)],
            subject: '下载 $downloadName',
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).translate('download_failed')}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkAndShowRating() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRated = prefs.getBool('has_rated') ?? false;
      if (hasRated) return;

      // Logic 1: Second download
      int downloadCount = (prefs.getInt('download_count') ?? 0) + 1;
      await prefs.setInt('download_count', downloadCount);

      if (downloadCount == 2) {
        _showRatingDialog();
      }
    } catch (e) {
      // ignore
    }
  }

  void _showRatingDialog() {
    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context).translate('give_rating')),
        content: Text('如果您觉得绘库设计资源不错，请给我们一个好评支持一下吧！'),
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

              // Replace with your app store URL
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;

    // Calculate scale and border radius based on drag progress
    // Scale goes from 1.0 -> 0.85
    final double scale = 1.0 - (_dragProgress * 0.15);
    // Radius goes from 0 -> 40
    final double radius = _dragProgress * 40.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Global Blur Background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels < -120) {
                if (mounted) Navigator.maybePop(context);
              }
              return false;
            },
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                // Only handle drag if we are at the top of the scroll view
                if (_scrollController.hasClients &&
                    _scrollController.offset <= 0) {
                  setState(() {
                    _dragProgress +=
                        (details.primaryDelta ?? 0) /
                        150; // Increased sensitivity
                    if (_dragProgress < 0) _dragProgress = 0;
                    if (_dragProgress > 1) _dragProgress = 1;
                  });
                }
              },
              onVerticalDragEnd: (details) {
                if (_dragProgress > 0.15) {
                  Navigator.pop(context);
                } else {
                  setState(() {
                    _dragProgress = 0.0;
                  });
                }
              },
              child: Transform.scale(
                scale: scale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Container(
                    color: bg,
                    child: Stack(
                      children: [
                        CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            SliverAppBar(
                              expandedHeight: 500.0,
                              backgroundColor: bg,
                              elevation: 0,
                              pinned: false,
                              stretch: true,
                              leading: const SizedBox(),
                              flexibleSpace: FlexibleSpaceBar(
                                stretchModes: const [
                                  StretchMode.zoomBackground,
                                ],
                                background: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Image Background
                                    _buildHeroImage(),
                                    // Gradient Overlay
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.0),
                                            Colors.black.withOpacity(0.2),
                                            Colors.black.withOpacity(0.8),
                                          ],
                                          stops: const [0.5, 0.7, 1.0],
                                        ),
                                      ),
                                    ),
                                    // Title Content
                                    Positioned(
                                      bottom: 24,
                                      left: 24,
                                      right: 24,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (widget.material.type.isEmpty
                                                    ? 'UNKNOWN'
                                                    : AppLocalizations.of(
                                                        context,
                                                      ).translate(
                                                        'tab_${widget.material.type.toLowerCase()}',
                                                      ))
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            widget.material.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 32,
                                              fontWeight: FontWeight.w800,
                                              height: 1.1,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          // Tags
                                          if (widget
                                              .material
                                              .tags
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: widget.material.tags.map((
                                                tag,
                                              ) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.3),
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    tag,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Content
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  32,
                                  24,
                                  120,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Supported Software Section
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      ).translate('support_software'),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black54,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildSoftwareList(isDark),

                                    // File List
                                    _buildFileList(isDark),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Top Right Close
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 10,
                          right: 20,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _dragProgress > 0.1 ? 0.0 : 1.0,
                            child: _buildBlurButton(
                              icon: CupertinoIcons.xmark,
                              onTap: () => Navigator.pop(context),
                              iconSize: 16,
                              weight: 20,
                            ),
                          ),
                        ),

                        // Top Right Share (Removed)
                        // Positioned(
                        //   top: MediaQuery.of(context).padding.top + 10,
                        //   right: 20,
                        //   child: AnimatedOpacity(
                        //     duration: const Duration(milliseconds: 200),
                        //     opacity: _dragProgress > 0.1 ? 0.0 : 1.0,
                        //     child: _buildBlurButton(
                        //       icon: null,
                        //       customIcon: const Icon(
                        //         CupertinoIcons.chat_bubble_2_fill,
                        //         color: Colors.white,
                        //         size: 20,
                        //       ),
                        //       onTap: _handleWeChatShare,
                        //     ),
                        //   ),
                        // ),

                        // Bottom Background
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 120,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _dragProgress > 0.1 ? 0.0 : 1.0,
                            child: Container(color: bg),
                          ),
                        ),

                        // Bottom Floating Get Button
                        Positioned(
                          bottom: 40,
                          left: 24,
                          right: 24,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _dragProgress > 0.1 ? 0.0 : 1.0,
                            child: _buildGetButton(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoftwareList(bool isDark) {
    // Priority: SoftwareObjects -> SupportedSoftware (String) -> Software (String) -> Fallback
    List<dynamic> listToRender = [];

    if (widget.material.softwareObjects.isNotEmpty) {
      listToRender = widget.material.softwareObjects;
    } else if (widget.material.supportedSoftware.isNotEmpty) {
      listToRender = widget.material.supportedSoftware;
    } else if (widget.material.software.isNotEmpty) {
      listToRender = [widget.material.software];
    } else {
      listToRender = ['通用'];
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: listToRender
            .map(
              (sw) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildSoftwareIcon(sw, isDark),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFileList(bool isDark) {
    if (widget.material.files.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          '文件列表', // Hardcoded as requested
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.material.files.map((file) => _buildFileItem(file, isDark)),
      ],
    );
  }

  Widget _buildFileItem(MaterialFile file, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Preview
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              image: file.previewUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(file.previewUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: file.previewUrl.isEmpty
                ? Icon(CupertinoIcons.doc_fill, color: Colors.grey, size: 24)
                : null,
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${file.format.toUpperCase()} · ${file.size}',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Download Button
          GestureDetector(
            onTap: () => _handleFileDownload(file),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.arrow_down_circle_fill,
                color: Color(0xFF007AFF),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoftwareIcon(dynamic item, bool isDark) {
    String name = '';
    String? logoUrl;

    if (item is SoftwareModel) {
      name = item.name;
      logoUrl = item.logo;
    } else {
      name = item.toString();
    }

    Color iconColor;
    String initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    // Try to find matching software from API list
    if (logoUrl == null || logoUrl.isEmpty) {
      final match = _supportedSoftwareList.firstWhere(
        (s) => s.name.toLowerCase() == name.toLowerCase(),
        orElse: () => Software(id: '', name: '', iconUrl: ''),
      );
      if (match.iconUrl.isNotEmpty) logoUrl = match.iconUrl;
    }

    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white, // White background for icons
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Image.network(
              logoUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Text(
                initials,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    // Fallback to Simple color mapping based on name
    if (name.toLowerCase().contains('ps') ||
        name.toLowerCase().contains('photoshop')) {
      iconColor = const Color(0xFF31A8FF);
      initials = 'Ps';
    } else if (name.toLowerCase().contains('ai') ||
        name.toLowerCase().contains('illustrator')) {
      iconColor = const Color(0xFFFF9A00);
      initials = 'Ai';
    } else if (name.toLowerCase().contains('pr') ||
        name.toLowerCase().contains('premiere')) {
      iconColor = const Color(0xFF9999FF);
      initials = 'Pr';
    } else if (name.toLowerCase().contains('ae') ||
        name.toLowerCase().contains('after')) {
      iconColor = const Color(0xFFD099FF);
      initials = 'Ae';
    } else if (name.toLowerCase().contains('figma')) {
      iconColor = Colors.black;
      initials = 'Fg';
    } else if (name.toLowerCase().contains('sketch')) {
      iconColor = const Color(0xFFFFB300);
      initials = 'Sk';
    } else {
      iconColor = Colors.grey;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(
              color: iconColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    Widget imageWidget;
    if (widget.material.thumbnail.isEmpty) {
      imageWidget = Container(color: Colors.grey);
    } else {
      // Check if it's a valid URL
      final uri = Uri.tryParse(widget.material.thumbnail);
      if (uri == null || !uri.hasScheme) {
        imageWidget = Container(color: Colors.grey);
      } else {
        imageWidget = Image.network(
          widget.material.thumbnail,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey),
        );
      }
    }

    return Hero(tag: 'material_${widget.material.id}', child: imageWidget);
  }

  String _getSafeFileExtension(String url) {
    if (url.isEmpty) return 'UNKNOWN';
    try {
      if (!url.contains('.')) return 'FILE';
      return url.split('.').last.toUpperCase();
    } catch (e) {
      return 'FILE';
    }
  }

  Widget _buildBlurButton({
    required IconData? icon,
    required VoidCallback onTap,
    double iconSize = 20,
    double? weight,
    Widget? customIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child:
                customIcon ??
                Icon(icon, color: Colors.white, size: iconSize, weight: weight),
          ),
        ),
      ),
    );
  }

  Widget _buildGetButton(BuildContext context) {
    if (_isDownloading) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              '${(_downloadProgress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Favorite Button
        GestureDetector(
          onTap: _toggleFavorite,
          child: Container(
            height: 56,
            width: 56,
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ScaleTransition(
              scale: _favScaleAnimation,
              child: Icon(
                _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: _isFavorite ? Colors.red : Colors.white,
                size: 24,
              ),
            ),
          ),
        ),

        // Share Button (Expanded)
        Expanded(
          child: GestureDetector(
            onTap: _handleWeChatShare,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF07C160),
                    Color(0xFF33D17D),
                  ], // WeChat Green
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF07C160).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.chat_bubble_2_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context).translate('share_friends'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
