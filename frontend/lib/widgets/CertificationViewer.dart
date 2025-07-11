import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';

class CertificationViewer extends StatelessWidget {
  final String fileUrl;

  CertificationViewer({required this.fileUrl});

  bool get isPdf => fileUrl.toLowerCase().endsWith('.pdf');
  bool get isImage => fileUrl.toLowerCase().endsWith('.jpg') ||
                      fileUrl.toLowerCase().endsWith('.jpeg') ||
                      fileUrl.toLowerCase().endsWith('.png');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Certification')),
      body: Center(
        child: isPdf
            ? SfPdfViewer.network(fileUrl)
            : isImage
              ? PhotoView(
                  imageProvider: NetworkImage(fileUrl),
                  backgroundDecoration: BoxDecoration(color: Colors.white),
                )
              : Text('Unsupported file type'),
      ),
    );
  }
}
