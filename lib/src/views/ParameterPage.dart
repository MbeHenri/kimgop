import 'package:flutter/material.dart';
import '../models/car_chimique_model.dart';
import '../models/matiere_premiere_model.dart';
import '../models/tab_recommanation.dart';
import '../utils.dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import '../repository/SqliteDatabase.dart';

class ParameterPage extends StatefulWidget {
  static String url = "/settings";
  const ParameterPage({Key? key}) : super(key: key);

  @override
  State<ParameterPage> createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  // variables permattant de verifier le chargement de la page
  bool loadAnalyse = false;
  bool loadMatiere = false;
  bool loadRecommand = false;

  Map<CarChimique, bool> mapControlerAnalyse = {};

  updateAnalyse() async {
    sq.Database? database = await SqliteDatabase.db.database;
    if (database != null) {
      var list = database.select("""
        SELECT * FROM car_chimique
      """);
      setState(() {
        mapControlerAnalyse.clear();
        loadAnalyse = true;
        for (var row in list) {
          mapControlerAnalyse.addAll({
            CarChimique(
                abreviation: row["abreviation"],
                idCarParent: null,
                id: row["id"],
                isDefault: row['isDefault'],
                nom: row['nom'],
                idUnite: row['idUnite']): row['isDefault'] == 1 ? true : false
          });
        }
      });
    }
  }

  Map<MatierePremiere, bool> mapControlerMatiere = {};
  updateMatiere() async {
    sq.Database? database = await SqliteDatabase.db.database;
    if (database != null) {
      var list = database.select("""
        SELECT * FROM matiere_premiere
      """);
      setState(() {
        mapControlerMatiere.clear();
        loadMatiere = true;
        for (var row in list) {
          mapControlerMatiere.addAll({
            MatierePremiere(
                abreviation: row["abreviation"],
                id: row["id"],
                isDefault: row['isDefault'],
                nom: row['nom']): row['isDefault'] == 1 ? true : false
          });
        }
      });
    }
  }

  List<TabRecommandation> listTabRecommandation = [];

  updateRecommand() async {
    sq.Database? database = await SqliteDatabase.db.database;
    if (database != null) {
      var list1 = database.select("""
        select * from table_recommandation
      """);
      var list2 =
          database.select("select s.idTabRecommandUse from systeme as s");
      setState(() {
        loadRecommand = true;
        for (var row in list2) {
          idTabRecomandCurrent = row['idTabRecommandUse'];
        }
        listTabRecommandation.clear();
        for (var row in list1) {
          listTabRecommandation
              .add(TabRecommandation(id: row["id"], etiquete: row['etiquete']));
        }
      });
    }
  }

  //on initialise l'etat "idTabRecomandCurrent" par Systeme.getIdTabRecommandCurrent
  //int ? idTabRecomandCurrent = Systeme.getIdTabRecommandCurrent(database)

  int? idTabRecomandCurrent;

  DropdownButton<int?> listTabRecommandationWidget() {
    List<DropdownMenuItem<int?>> list = [
      const DropdownMenuItem<int?>(
        value: null,
        child: Text("----"),
      )
    ];
    for (var e in listTabRecommandation) {
      list.add(DropdownMenuItem<int>(
        value: e.id,
        child: Text(e.etiquete),
      ));
    }
    return DropdownButton<int?>(
      items: list,
      value: idTabRecomandCurrent,
      onChanged: (value) async {
        sq.Database? database = await SqliteDatabase.db.database;
        if (database != null) {
          try {
            database.execute(
                "update systeme set idTabRecommandUse=$value where id=1");
            // ignore: empty_catches
          } catch (e) {}
        }
        setState(() {
          idTabRecomandCurrent = value;
        });
      },
      isExpanded: true,
    );
  }

  Widget swichListCaracteristique() {
    List<Widget> list = [];
    for (var key in mapControlerAnalyse.keys) {
      list.add(SwitchListTile(
          title: Text(key.nom),
          subtitle: Text(key.abreviation),
          value: mapControlerAnalyse[key]!,
          activeColor: secondaryDarkColor(),
          onChanged: ((value) async {
            sq.Database? database = await SqliteDatabase.db.database;
            if (database != null) {
              try {
                database.execute(
                    "update car_chimique set isDefault=${value ? 1 : 0} where id=${key.id}");
                // ignore: empty_catches
              } catch (e) {}
            }
            setState(() {
              mapControlerAnalyse[key] = value;

              /* gestion modification du caractere d'axe d'analyse de la caracteristique chimique */
            });
          })));
    }
    return list.isEmpty
        ? const Center(
            child: Text("aucuns axes d'analyse existants, veillez en ajouter"),
          )
        : Column(
            children: list,
          );
  }

  Widget swichListMatiere() {
    List<Widget> list = [];
    for (var key in mapControlerMatiere.keys) {
      list.add(SwitchListTile(
          title: Text(key.nom),
          subtitle: Text(key.abreviation ?? ""),
          value: mapControlerMatiere[key]!,
          activeColor: secondaryDarkColor(),
          onChanged: ((value) async {
            sq.Database? database = await SqliteDatabase.db.database;
            if (database != null) {
              try {
                database.execute(
                    "update matiere_premiere set isDefault=${value ? 1 : 0} where id=${key.id}");
                // ignore: empty_catches
              } catch (e) {}
            }
            setState(() {
              mapControlerMatiere[key] = value;

              /* gestion modification du caractere d'axe d'analyse de la caracteristique chimique */
            });
          })));
    }
    return list.isEmpty
        ? const Center(
            child: Text("aucunes matières existants, veillez en ajouter"),
          )
        : Column(
            children: list,
          );
  }

  @override
  Widget build(BuildContext context) {
    if (!loadAnalyse) {
      updateAnalyse();
    }
    if (!loadMatiere) {
      updateMatiere();
    }
    if (!loadRecommand) {
      updateRecommand();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor(),
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
        title: const Text("Paramètres"),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(
                  Icons.analytics_rounded,
                  color: thirtyColor(),
                  size: 45,
                ),
                title: const Text(
                  "Axes d'analyse par défaut",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              swichListCaracteristique(),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.compost_outlined,
                  color: thirtyColor(),
                  size: 45,
                ),
                title: const Text(
                  "Matieres premieres par défaut",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              swichListMatiere(),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.recommend_outlined,
                  color: thirtyColor(),
                  size: 45,
                ),
                title: const Text(
                  "Table de recommandation par défaut",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              listTabRecommandationWidget(),
              const SizedBox(height: 20),
            ],
          )),
    );
  }
}
