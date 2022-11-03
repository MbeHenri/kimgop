/*import 'dart:async';
import 'package:sqflite/sqflite.dart';
*/
class TabComposition {
  final int id;
  late String titre;
  late double prixSub;
  late DateTime dateCreation;
  late DateTime dateModification;

  TabComposition(
      {required this.id,
      required this.titre,
      required this.prixSub,
      required this.dateCreation,
      required this.dateModification});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'prixSub': prixSub,
      'dateCreation': dateCreation,
      'dateModification': dateModification
    };
  }

  @override
  String toString() {
    return 'TabComposition{id: $id, titre: $titre}';
  }
/*
  Future<int> insert(Database database) async {
    return await database.rawInsert(
        "insert into table_composition (titre, prixSub, dateCreation, dateModification)"
        "values (?,?,?,?)",
        [titre, prixSub, DateTime.now(), DateTime.now()]);
  }

  Future<void> delete(Database database) async {
    await database
        .delete('table_composition', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Database database) async {
    await database
        .update('table_composition', toMap(), where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<TabComposition>> all(database) async {
    final List<Map<String, dynamic>> maps =
        await database.query('matiere_premiere');

    return List.generate(maps.length, (i) {
      return TabComposition(
          id: maps[i]['id'],
          titre: maps[i]['titre'],
          prixSub: maps[i]['prixSub'],
          dateCreation: maps[i]['dateCreation'],
          dateModification: maps[i]['dateModification']);
    });
  }*/
}
