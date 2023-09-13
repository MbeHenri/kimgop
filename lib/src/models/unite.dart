/*
import 'dart:async';
import 'package:sqflite/sqflite.dart';
*/
class Unite {
  late int id;
  late String nom;
  Unite({required this.id, required this.nom});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
    };
  }

  @override
  String toString() {
    return 'unite{id: $id, nom: $nom}';
  }
/*
  Future<Unite?> get(Database database, int id) async {
    final List<Map<String, dynamic>> map =
        await database.query('unite', where: 'id = ?', whereArgs: [id]);
    if (map.isNotEmpty) {
      return Unite(id: map[0]['id'], nom: map[0]['nom']);
    }
    return null;
  }
  Future<int> insert(Database database) async {
    return await database.rawInsert(
        "insert into unite (nom)"
        "values (?)",
        [nom]);
  }

  Future<void> delete(Database database) async {
    await database.delete('car_chimique', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Database database) async {
    await database.update('unite', toMap(), where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Unite>> all(Database database) async {
    final List<Map<String, dynamic>> maps =
        await database.query('car_chimique');

    return List.generate(maps.length, (i) {
      return Unite(
        id: maps[i]['id'],
        nom: maps[i]['nom'],
      );
    });
  }
*/
}
