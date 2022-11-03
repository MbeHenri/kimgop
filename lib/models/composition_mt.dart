/*import 'dart:async';
import 'package:sqflite/sqflite.dart';
*/
class CompositionMt {
  final int idMtP;
  final int idTabComp;
  late double quantite;
  late double pu;

  CompositionMt(
      {required this.idTabComp,
      required this.idMtP,
      required this.quantite,
      required this.pu});

  Map<String, dynamic> toMap() {
    return {
      'idMtP': idMtP,
      'idTabComp': idTabComp,
      'quantite': quantite,
      'pu': pu
    };
  }

  @override
  String toString() {
    return 'CompositionMt{idTabComp: $idTabComp, idMtP: $idMtP, quantite: $quantite}';
  }
/*
  Future<int> insert(Database database) async {
    return await database.rawInsert(
        "insert into composition_mt (idMtP, idTabComp, quantite)"
        "values (?, ?, ?)",
        [idMtP, idTabComp, quantite]);
  }

  Future<void> delete(Database database) async {
    await database.delete('composition_mt',
        where: 'idTabComp = ? and idMtP = ?', whereArgs: [idTabComp, idMtP]);
  }

  Future<void> update(Database database) async {
    await database.update('composition_mt', toMap(),
        where: 'idTabComp = ? and idMtP = ?', whereArgs: [idTabComp, idMtP]);
  }

  static Future<List<CompositionMt>> all(Database database) async {
    final List<Map<String, dynamic>> maps =
        await database.query('composition_mt');

    return List.generate(maps.length, (i) {
      return CompositionMt(
          idTabComp: maps[i]['idTabComp'],
          idMtP: maps[i]['idMtP'],
          quantite: maps[i]['quantite'],
          pu: maps[i]['pu']);
    });
  }*/

  static double prixMoyen(Iterable<CompositionMt> list) {
    double qt = 0;
    double pt = 0;
    for (var e in list) {
      if (e.quantite != 0 && e.pu != 0) {
        qt += e.quantite;
        pt += e.pu * e.quantite;
      }
    }
    if (qt != 0) {
      return pt / qt;
    }
    return 0;
  }
}
