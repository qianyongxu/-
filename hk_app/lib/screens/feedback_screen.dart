import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _contentCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final List<File> _images = [];
  final _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('最多上传3张图片')));
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  void _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请输入反馈内容')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService().submitFeedback(
        _contentCtrl.text,
        '', // Removed contact
        _images,
      );
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(l10n.translate('submit_success')),
            content: Text(l10n.translate('submit_success_msg')),
            actions: [
              CupertinoDialogAction(
                child: Text(l10n.translate('confirm')),
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close screen
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('提交失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black54;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.translate('feedback'), style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Stack(
        children: [
          // Background
          if (isDark) ...[
            Positioned(
              top: -100,
              right: -100,
              child: _buildAmbientOrb(Color(0xFF007AFF), 300),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ],

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGlassContainer(
                    isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.translate('problem_desc'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        SizedBox(height: 12),
                        TextField(
                          controller: _contentCtrl,
                          maxLines: 5,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: l10n.translate('problem_hint'),
                            hintStyle: TextStyle(color: secondaryTextColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  _buildGlassContainer(
                    isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.translate('image_attachment'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            ..._images.map((file) => Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _images.remove(file)),
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                      child: Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            if (_images.length < 3)
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
                                  ),
                                  child: Icon(Icons.add_photo_alternate, color: secondaryTextColor),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),

                  _buildGlassContainer(
                    isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.translate('contact_info'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        SizedBox(height: 12),
                        TextField(
                          controller: _contactCtrl,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: l10n.translate('contact_hint'),
                            hintStyle: TextStyle(color: secondaryTextColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Color(0xFF007AFF),
                        elevation: 0,
                      ),
                      child: _isSubmitting 
                          ? CupertinoActivityIndicator(color: Colors.white)
                          : Text(l10n.translate('submit_feedback'), style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildGlassContainer(bool isDark, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAmbientOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.4),
      ),
    );
  }
}
