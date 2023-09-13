import 'package:flutter/material.dart';
import 'src/utils.dart';
import 'src/views/ListTabRecommandation.dart';
import 'src/views/ParameterPage.dart';
import 'src/views/Home.dart';
import 'src/views/ListCarChimiquePage.dart';
import 'src/views/ListMatierePremierePage.dart';
import 'src/views/PdfPreviewPage.dart';
import 'src/views/TabAlimentationPage.dart';
import 'src/views/TabCompDetailPage.dart';
import 'src/views/TabRecommandationDetail.dart';

import 'src/views/ListTabCompositionPage.dart';

void main() {
  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
      color: primaryColor(),
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        HomePage.url: (context) => HomePage(),
        ListTabCompositionPage.url: (context) => const ListTabCompositionPage(),
        TabCompDetailPage.url: (context) => const TabCompDetailPage(),
        ListMatierePremierePage.url: (context) =>
            const ListMatierePremierePage(),
        ListCarChimiquePage.url: (contex) => const ListCarChimiquePage(),
        ParameterPage.url: (context) => const ParameterPage(),
        TabAlimentationPage.url: (context) => const TabAlimentationPage(),
        ListTabRecommandationPage.url: (context) =>
            const ListTabRecommandationPage(),
        TabRecommandationDetailPage.url: (context) =>
            const TabRecommandationDetailPage(),
        PdfPreviewPage.url: (context) =>
            const PdfPreviewPage(titre: "", flow: null),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
