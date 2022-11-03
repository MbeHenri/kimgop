/*import 'dart:async';
import 'package:sqflite/sqflite.dart';
*/
class ContenuChimique {
  final int idMtP;
  final int idCar;
  final double valeur;
  ContenuChimique(
      {required this.idCar, required this.idMtP, required this.valeur});
  Map<String, dynamic> toMap() {
    return {'idMtP': idMtP, 'idCar': idCar, 'valeur': valeur};
  }

  @override
  String toString() {
    return 'ContenuChimique{idCar: $idCar, idMtP: $idMtP, valeur: $valeur}';
  }
/*
  Future<int> insert(Database database) async {
    return await database.rawInsert(
        "insert into contenu_chimique (idMtP, idCar, valeur)"
        "values (?, ?, ?)",
        [idMtP, idCar, valeur]);
  }

  Future<void> delete(Database database) async {
    await database.delete('contenu_chimique',
        where: 'idCar = ? and idMtP = ?', whereArgs: [idCar]);
  }

  Future<void> update(Database database) async {
    await database.update('contenu_chimique', toMap(),
        where: 'idCar = ? and idMtP = ?', whereArgs: [idCar, idMtP]);
  }

  static Future<List<ContenuChimique>> all(database) async {
    final List<Map<String, dynamic>> maps =
        await database.query('contenu_chimique');

    return List.generate(maps.length, (i) {
      return ContenuChimique(
          idCar: maps[i]['id'],
          idMtP: maps[i]['idMtP'],
          valeur: maps[i]['valeur']);
    });
  }*/
}
