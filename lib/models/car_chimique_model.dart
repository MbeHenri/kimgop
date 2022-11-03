/*
import 'dart:async';
import 'package:sqflite/sqflite.dart';
*/
class CarChimique {
  late int id;
  late String nom;
  late String abreviation;
  late int? idCarParent;
  late int idUnite;
  late int isDefault;
  CarChimique(
      {required this.abreviation,
      required this.idCarParent,
      required this.id,
      required this.isDefault,
      required this.nom,
      required this.idUnite});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'abreviation': abreviation,
      'idCarParent': idCarParent,
      'isDefault': isDefault,
      'idUnite': idUnite,
    };
  }

  @override
  String toString() {
    return 'CarChimique{id: $id, nom: $nom, abrv: $abreviation, parent : $idCarParent}';
  }

/*
  Future<CarChimique?> get(Database database, int id) async {
    final List<Map<String, dynamic>> map =
        await database.query('car_chimique', where: 'id = ?', whereArgs: [id]);
    if (map.isNotEmpty) {
      return CarChimique(
        abreviation: map[0]['abreviation'],
        idCarParent: map[0]['idCarParent'],
        id: map[0]['id'],
        isDefault: map[0]['isDefault'],
        nom: map[0]['nom'],
        idUnite: map[0]['idUnite'],
      );
    }
    return null;
  }
  Future<int> insert(Database database) async {
    return await database.rawInsert(
        "insert into car_chimique (nom, abreviation, idCarParent, idUnite)"
        "values (?, ?, ?)",
        [nom, abreviation, idCarParent, idUnite]);
  }

  Future<void> delete(Database database) async {
    await database.delete('car_chimique', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Database database) async {
    await database
        .update('car_chimique', toMap(), where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<CarChimique>> all(Database database) async {
    final List<Map<String, dynamic>> maps =
        await database.query('car_chimique');

    return List.generate(maps.length, (i) {
      return CarChimique(
          id: maps[i]['id'],
          nom: maps[i]['nom'],
          abreviation: maps[i]['abreviation'],
          idCarParent: maps[i]['idCarParent'],
          isDefault: maps[i]['id_default'],
          idUnite: maps[i]['idUnite']);
    });
  }*/
}
