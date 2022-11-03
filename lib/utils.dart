import 'dart:ui';
import 'package:pdf/pdf.dart';

String getTime(DateTime date) {
  DateTime now = DateTime.now();
  Duration varTime = now.difference(date);

  if (varTime.inDays < 7) {
    if (varTime.inDays < 2) {
      if (varTime.inDays == 0) {
        if (varTime.inHours < 2) {
          return "recemment";
        } else {
          return "${date.hour} heures";
        }
      } else {
        return "hier";
      }
    } else {
      return "${date.day} jours";
    }
  } else if (varTime.inDays == 7) {
    return "une semaine";
  } else {
    return date.toString();
  }
}

Color primaryColor() {
  return const Color.fromARGB(255, 19, 44, 23);
}

Color secondaryColor() {
  return const Color.fromARGB(255, 239, 119, 60);
}

Color thirtyColor() {
  return const Color.fromARGB(255, 18, 113, 57);
}

Color thirtyColorBlur() {
  return const Color.fromARGB(65, 18, 113, 57);
}

Color secondaryColorBlur() {
  return const Color.fromARGB(175, 239, 119, 60);
}

Color secondaryDarkColor() {
  return const Color.fromARGB(255, 207, 87, 27);
}

Color primaryColorBlur() {
  return const Color.fromARGB(175, 19, 44, 23);
}

Color colorOKRecommand() {
  return const Color.fromARGB(219, 84, 120, 5);
}

Color colorNotRecommand() {
  return const Color.fromARGB(219, 133, 38, 17);
}

Color colorAnyRecommand() {
  return const Color.fromARGB(219, 15, 10, 6);
}

Color colorRecommand(double valMoyenne, double ecartAcceptable, double value) {
  if (valMoyenne != 0 && ecartAcceptable != 0) {
    if (valMoyenne + ecartAcceptable > value &&
        valMoyenne - ecartAcceptable < value) {
      return colorOKRecommand();
    } else {
      return colorNotRecommand();
    }
  }
  return colorAnyRecommand();
}

String expReguliereReel() {
  return r'[0-9]+[,.]{0,1}[0-9]*';
}

PdfColor pdfColorOKRecommand() {
  return PdfColor.fromRYB(84, 120, 5, 1);
}

PdfColor pdfColorNotRecommand() {
  return PdfColor.fromRYB(133, 38, 17, 1);
}

PdfColor pdfColorAnyRecommand() {
  return PdfColor.fromRYB(15, 10, 6, 1);
}

PdfColor pdfColorRecommand(
    double valMoyenne, double ecartAcceptable, double value) {
  if (valMoyenne != 0 && ecartAcceptable != 0) {
    if (valMoyenne + ecartAcceptable > value &&
        valMoyenne - ecartAcceptable < value) {
      return pdfColorOKRecommand();
    } else {
      return pdfColorNotRecommand();
    }
  }
  return pdfColorAnyRecommand();
}
