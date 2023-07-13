import 'package:flutter/material.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class PDFViewer extends StatelessWidget {
  final String path;
  const PDFViewer({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text("PDF VIEWER"),
          Expanded(child: PdfView(path: path)),
        ],
      ),
    );
  }
}