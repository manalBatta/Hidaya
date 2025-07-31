import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;
import 'package:universal_html/html.dart' as html;

class WebPdfViewer extends StatelessWidget {
  final String fileUrl;
  const WebPdfViewer({Key? key, required this.fileUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      fileUrl,
      (int viewId) => html.IFrameElement()
        ..src = fileUrl
        ..style.border = 'none'
        ..width = '100%'
        ..height = '100%',
    );
    
    return SizedBox(
      width: double.infinity,
      height: 600,
      child: HtmlElementView(viewType: fileUrl),
    );
  }
} 