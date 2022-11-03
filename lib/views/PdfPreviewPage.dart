import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../utils.dart';

class PdfPreviewPage extends StatelessWidget {
  final String titre;
  final Uint8List? flow;
  static String url = "/viewpdf";
  const PdfPreviewPage({Key? key, required this.titre, required this.flow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: secondaryColor()),
              onPressed: () {
                Navigator.pop(context);
              },
              tooltip: "retourner en arriere",
            );
          },
        ),
        title: Text(titre),
        backgroundColor: primaryColor(),
      ),
      body: flow == null
          ? const Text("Aucun pdf")
          : PdfPreview(
              build: (context) => flow!,
              pdfFileName: titre,
            ),
    );
  }
}
