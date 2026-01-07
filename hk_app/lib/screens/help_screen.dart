import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -50,
            right: -50,
            child: _buildAmbientOrb(Color(0xFF007AFF), 200),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '帮助与指南',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          child: Icon(CupertinoIcons.xmark, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildVideoGuide(
                        '如何导入笔刷？',
                        'assets/videos/brush_tutorial.mp4', // Placeholder for video
                        '1. 在笔刷详情页点击"下载"。\n2. 下载完成后，选择"在 Procreate 中打开"。\n3. 笔刷组将自动导入到您的画笔库中。',
                        CupertinoIcons.paintbrush,
                      ),
                      SizedBox(height: 16),
                      _buildVideoGuide(
                        '如何安装字体？',
                        'assets/videos/font_tutorial.mp4',
                        '1. 下载字体文件（通常是 .ttf 或 .otf）。\n2. 使用 iFont 等配置描述文件工具安装。\n3. 前往 设置 > 通用 > VPN与设备管理 激活配置。',
                        CupertinoIcons.textformat,
                      ),
                      SizedBox(height: 16),
                      _buildFAQItem(
                        '下载的文件在哪里？',
                        '所有下载的文件都会保存到您设备自带的"文件" App 中的 "下载" 文件夹内。您可以在那里对文件进行管理和解压。',
                        CupertinoIcons.folder,
                      ),
                      SizedBox(height: 16),
                      _buildFAQItem(
                        '素材可以商用吗？',
                        'App 内的大部分素材仅供个人学习和非商业使用。如果需要商用授权，请查看具体素材详情页的授权说明，或联系作者获取授权。',
                        CupertinoIcons.money_dollar_circle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        color: color.withOpacity(0.4),
      ),
    );
  }

  Widget _buildVideoGuide(String question, String videoPath, String steps, IconData icon) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.purple, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Fake Video Player Container
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(CupertinoIcons.play_circle_fill, size: 50, color: Colors.white.withOpacity(0.8)),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '视频教程',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            steps,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, IconData icon) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blue, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            answer,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
