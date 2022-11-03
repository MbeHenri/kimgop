import 'package:flutter/material.dart';
import 'package:kimgop/utils.dart';
import 'package:kimgop/views/ListTabRecommandation.dart';
import 'package:kimgop/views/ParameterPage.dart';
import 'package:kimgop/views/Home.dart';
import 'package:kimgop/views/ListCarChimiquePage.dart';
import 'package:kimgop/views/ListMatierePremierePage.dart';
import 'package:kimgop/views/PdfPreviewPage.dart';
import 'package:kimgop/views/TabAlimentationPage.dart';
import 'package:kimgop/views/TabCompDetailPage.dart';
import 'package:kimgop/views/TabRecommandationDetail.dart';

import 'package:kimgop/views/ListTabCompositionPage.dart';

void main() {
  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
      theme: ThemeData(primaryColor: primaryColor()),
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
