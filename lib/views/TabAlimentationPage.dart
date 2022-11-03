import 'package:flutter/material.dart';
import 'package:kimgop/models/contenu_chimique.dart';
import 'package:flutter/services.dart';
import 'package:kimgop/utils.dart';

import '../utils.dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import 'package:kimgop/repository/SqliteDatabase.dart';

class TabAlimentationPage extends StatefulWidget {
  static String url = "/tabAlimentaire";
  const TabAlimentationPage({Key? key}) : super(key: key);

  @override
  State<TabAlimentationPage> createState() => _TabAlimentationPageState();
}

class _TabAlimentationPageState extends State<TabAlimentationPage> {
  Map<String, Map<String, ContenuChimique>> maps = {};
  Map<String, Map<String, TextEditingController>> controleur = {};
  DataTable? tabs;
  bool load = false;
  bool isInit = false;
  // boolean permettant de verifier s'il ya une modification au niveau des controleurs
  bool isChanged = false;

  @override
  void dispose() {
    controleur.forEach((key, value) {
      value.forEach((kety, val) {
        val.dispose();
      });
    });
    super.dispose();
  }

  //chargement de la map de conteneur chimique
  loadingMaps() async {
    sq.Database? database = await SqliteDatabase.db.database;
    if (database != null) {
      var list = database.select("""
        SELECT mp.id as id_mp, carch.id as id_car, conch.valeur, mp.nom as nom_mp, carch.nom as nom_car 
        from car_chimique as carch, contenu_chimique as conch, matiere_premiere as mp 
        where carch.id = conch.idCar and conch.idMtP = mp.id 
        ORDER by carch.nom; 
      """);
      String nomCurrent = "";
      setState(() {
        maps.clear();
        load = true;
        for (var row in list) {
          if (row["nom_car"] != nomCurrent) {
            nomCurrent = row["nom_car"];
            maps.addAll({nomCurrent: {}});
          }
          maps[nomCurrent]?.addAll({
            row["nom_mp"].toString(): ContenuChimique(
                idCar: row["id_car"],
                idMtP: row["id_mp"],
                valeur: row["valeur"])
          });
        }
      });
    }
  }

  initTextEditeur() {
    maps.forEach((mp, value) {
      controleur.addAll({mp: {}});
      value.forEach((ech, reel) {
        controleur[mp]?.addAll(
            {ech: TextEditingController(text: reel.valeur.toString())});
      });
    });
  }

  updateDataTable() {
    List<DataRow> lignes = [];
    List<String> cols = [];
    controleur.forEach((mp, value) {
      List<DataCell> ligne = [DataCell(Text(mp.toString()))];
      String val = "matieres";
      if (!cols.contains(val)) {
        cols.add(val);
      }
      value.forEach((ech, reel) {
        val = ech;
        if (!cols.contains(val)) {
          cols.add(val);
        }
        ligne.add(DataCell(TextField(
          controller: controleur[mp]![ech],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(expReguliereReel())),
            TextInputFormatter.withFunction((oldValue, newValue) =>
                newValue.copyWith(text: newValue.text.replaceAll(',', '.')))
          ],
          decoration: InputDecoration(
            fillColor: primaryColor(),
          ),
          onChanged: (value) {
            setState(() {
              isChanged = true;
            });
          },
        )));
      });
      lignes.add(DataRow(cells: ligne));
    });
    List<DataColumn> colones = [];
    for (var e in cols) {
      colones.add(DataColumn(label: Text(e,style: const TextStyle(color: Colors.white),)));
    }
    return DataTable(
      columns: colones,
      rows: lignes,
      dataRowColor:
          MaterialStateProperty.resolveWith((states) => thirtyColorBlur()),
      headingRowColor:
          MaterialStateProperty.resolveWith((states) => primaryColor()),
    );
  }

  Widget contentwidget(BuildContext context) {
    if (maps.isEmpty) {
      return const Text("la table est innnexistante");
    }

    if (!isInit) {
      initTextEditeur();
      tabs = updateDataTable();

      if (tabs == null) {
        return const Text("un probleme au niveau des composition est survenu");
      }
      isInit = true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: tabs ?? const Text("data")),
    );
  }

// fonction permettant de construire la liste des des boutons d'actions du menu
  List<Widget> listActionButton(BuildContext context) {
    List<Widget> list = [];
    if (isChanged) {
      list.insert(
          0,
          IconButton(
            onPressed: () {
              saveAnyCorrect();
              setState(() {
                isChanged = false;
              });
            },
            icon: const Icon(
              Icons.save,
              color: Colors.blue,
            ),
            tooltip: "sauvegarder les modifications",
          ));
    }
    return list;
  }

  // fonction permettant de sauvegarder les modificaion possible et d'actualiser la vue
  saveAnyCorrect() async {
    sq.Database? database = await SqliteDatabase.db.database;
    controleur.forEach((key1, value) {
      value.forEach((key2, value) {
        if (value.text != "" && database != null) {
          try {
            database.execute("UPDATE contenu_chimique SET valeur=${value.text} "
                "WHERE idMtP=${maps[key1]![key2]!.idMtP} and idCar=${maps[key1]![key2]!.idCar} ");
            // ignore: empty_catches
          } catch (e) {}
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!load) {
      loadingMaps();
    }

    return Scaffold(
      appBar: AppBar(
        actions: listActionButton(context),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: secondaryColor()),
              onPressed: () {
                Navigator.pop(context);
              },
              tooltip: "retourner en arriere",
            );
          },
        ),
        title: const Text("Tableau d'alimentation"),
        backgroundColor: primaryColor(),
      ),
      body: contentwidget(context),
    );
  }
}
