/*import 'dart:async';
import 'package:sqflite/sqflite.dart';
*/
class RecommandationCarChi {
  final int idCarChi;
  final int idTabRecommandation;
  late double valeurMoyenne;
  late double ecartAcceptable;

  RecommandationCarChi(
      {required this.idTabRecommandation,
      required this.idCarChi,
      required this.valeurMoyenne,
      required this.ecartAcceptable});

  Map<String, dynamic> toMap() {
    return {
      'idCarChi': idCarChi,
      'idTabRecommandation': idTabRecommandation,
      'valeurMoyenne': valeurMoyenne,
      'ecartAcceptable': ecartAcceptable
    };
  }

  @override
  String toString() {
    return 'recommandation_car_chi{idTabRecommandation: $idTabRecommandation, idCarChi: $idCarChi, valeurMoyenne: $valeurMoyenne, ecartAcceptable $ecartAcceptable}';
  }
/*
  Future<int> insert(Database database) async {
    return await database.rawInsert(
        "insert into recommandation_car_chi (idCarChi, idTabRecommandation, valeurMoyenne)"
        "values (?, ?, ?)",
        [idCarChi, idTabRecommandation, valeurMoyenne]);
  }

  Future<void> delete(Database database) async {
    await database.delete('recommandation_car_chi',
        where: 'idTabRecommandation = ? and idCarChi = ?',
        whereArgs: [idTabRecommandation, idCarChi]);
  }

  Future<void> update(Database database) async {
    await database.update('recommandation_car_chi', toMap(),
        where: 'idTabRecommandation = ? and idCarChi = ?',
        whereArgs: [idTabRecommandation, idCarChi]);
  }

  static Future<List<RecommandationCarChi>> all(Database database) async {
    final List<Map<String, dynamic>> maps =
        await database.query('recommandation_car_chi');

    return List.generate(maps.length, (i) {
      return RecommandationCarChi(
          idTabRecommandation: maps[i]['idTabRecommandation'],
          idCarChi: maps[i]['idCarChi'],
          valeurMoyenne: maps[i]['valeurMoyenne'],
          ecartAcceptable: maps[i]['ecartAcceptable']);
    });
  }*/
}
