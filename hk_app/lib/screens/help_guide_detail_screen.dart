import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/app_models.dart';

class HelpGuideDetailScreen extends StatelessWidget {
  final HelpGuide guide;
  const HelpGuideDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.black,
        middle: Text(guide.title, style: TextStyle(color: Colors.white)),
        leading: CupertinoNavigationBarBackButton(color: Colors.white, onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
         padding: EdgeInsets.all(16),
         child: Html(
            data: guide.content,
            style: {
               "body": Style(color: Colors.white, fontSize: FontSize(16)),
               "img": Style(margin: Margins.symmetric(vertical: 10)),
               "p": Style(lineHeight: LineHeight(1.6)),
            },
         ),
      ),
    );
  }
}
