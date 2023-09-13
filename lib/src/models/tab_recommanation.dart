/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
*/
import './systeme.dart';

class TabRecommandation {
  final int id;
  late String etiquete;
  late int idSysteme = Systeme.id;

  TabRecommandation({required this.id, required this.etiquete});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'etiquete': etiquete,
    };
  }

  @override
  String toString() {
    return 'TabRecommandation{id: $id, etiquete: $etiquete}';
  }
/*
  Future<int> insert(Database database) async {
    return await database.rawInsert(
        "insert into table_recommandation (etiquete)"
        "values (?)",
        [etiquete]);
  }

  Future<void> delete(Database database) async {
    await database
        .delete('table_recommandation', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Database database) async {
    await database.update('table_recommandation', toMap(),
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<TabRecommandation>> all(database) async {
    final List<Map<String, dynamic>> maps =
        await database.query('matiere_premiere');

    return List.generate(maps.length, (i) {
      return TabRecommandation(
        id: maps[i]['id'],
        etiquete: maps[i]['etiquete'],
      );
    });
  }*/
}
