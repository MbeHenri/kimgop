/*import 'dart:async';
import 'package:sqflite/sqflite.dart';
*/
class Systeme {
  static final int id = 1;
  static late int? idTabRecommandUse;
  Systeme();
  static Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idTabRecommandUse': idTabRecommandUse,
    };
  }

  @override
  String toString() {
    return 'Systeme{id: $id, idTabRecommandUse: $idTabRecommandUse}';
  }
/*
  static Future<int?> getIdTabRecommandCurrent(Database database) async {
    final List<Map<String, dynamic>> map =
        await database.query('systeme', where: 'id = ?', whereArgs: [id]);
    if (map.isNotEmpty) {
      return map[0]['idTabRecommandUse'];
    }
    return null;
  }


  static Future<void> update(Database database) async {
    await database.update('systeme', toMap(), where: 'id = ?', whereArgs: [id]);
  }*/
}
