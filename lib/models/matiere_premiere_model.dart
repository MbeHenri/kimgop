/*import 'dart:async';
import 'package:sqflite/sqflite.dart';
*/
class MatierePremiere {
  late int id;
  late String nom;
  late String? abreviation;
  late int isDefault;
  MatierePremiere(
      {required this.abreviation,
      required this.id,
      required this.isDefault,
      required this.nom});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'abreviation': abreviation,
      'isDefault': isDefault
    };
  }

  @override
  String toString() {
    return 'MatierePremiere{id: $id, nom: $nom, abrv: $abreviation}';
  }
/*
  Future<MatierePremiere?> get(Database database, int id) async {
    final List<Map<String, dynamic>> map = await database
        .query('matiere_premiere', where: 'id = ?', whereArgs: [id]);
    if (map.isNotEmpty) {
      return MatierePremiere(
          abreviation: map[0]['abreviation'],
          id: map[0]['id'],
          isDefault: map[0]['isDefault'],
          nom: map[0]['nom']);
    }
    return null;
  }

  Future<int> insert(Database database) async {
    return await database.rawInsert(
        "insert into matiere_premiere (nom, abreviation)"
        "values (?, ?)",
        [nom, abreviation]);
  }

  Future<void> delete(Database database) async {
    await database.delete('matiere_premiere', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Database database) async {
    await database
        .update('matiere_premiere', toMap(), where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<MatierePremiere>> all(database) async {
    final List<Map<String, dynamic>> maps =
        await database.query('matiere_premiere');

    return List.generate(maps.length, (i) {
      return MatierePremiere(
          id: maps[i]['id'],
          nom: maps[i]['nom'],
          abreviation: maps[i]['abreviation'],
          isDefault: maps[i]['idDefault']);
    });
  }*/
}
