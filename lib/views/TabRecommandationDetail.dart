import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kimgop/models/recommandation_car_chi.dart';
import 'package:kimgop/models/tab_recommanation.dart';
import 'package:kimgop/utils.dart';
import 'package:kimgop/views/FormTabRecommandPage..dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import 'package:kimgop/repository/SqliteDatabase.dart';

class TabRecommandationDetailPage extends StatefulWidget {
  static String url = '/details/TabRecommandation';

  const TabRecommandationDetailPage({Key? key}) : super(key: key);

  @override
  State<TabRecommandationDetailPage> createState() => _TabCompPageState();
}

class _TabCompPageState extends State<TabRecommandationDetailPage> {
  // boolean permettant de verifier s'il ya une modification au niveau des controleurs
  bool isChanged = false;
  // fonction permettant de verifier que la vue a ete innitialiser
  bool isInit = false;
  bool isLoad = false;
  late TabRecommandation _tab = TabRecommandation(id: -1, etiquete: "");

  // dictionnaire des compositions alimentaire du tableau
  Map<String, RecommandationCarChi> comps = {};
  updateComps() async {
    sq.Database? database = await SqliteDatabase.db.database;
    if (database != null) {
      var list = database.select(
          "SELECT c.nom , r.idCarChi, r.idTabRecommandation, r.valeurMoyenne, r.ecartAcceptable "
          "FROM car_chimique as c, recommandation_car_chi as r "
          "WHERE c.id = r.idCarChi and  c.isDefault = 1 and r.idTabRecommandation = ${_tab.id} "
          "ORDER BY c.nom ;");
      setState(() {
        isLoad = true;
        comps.clear();
        for (var row in list) {
          comps.addAll({
            row['nom']: RecommandationCarChi(
                idTabRecommandation: row['idTabRecommandation'],
                idCarChi: row['idCarChi'],
                valeurMoyenne: row['valeurMoyenne'],
                ecartAcceptable: row['ecartAcceptable'])
          });
        }
      });
    }
  }

  Map<String, Map<String, TextEditingController>> controleur = {};
  String titreCourant = "";

  @override
  void dispose() {
    controleur.forEach((key, value) {
      value.forEach((kety, val) {
        val.dispose();
      });
    });
    super.dispose();
  }

  DataTable? tabRecommandations;

  void actualiser(TabRecommandation newTab) {
    setState(() {
      //actualiser "comps" structure des compositions dependant des matieres premieres par default
      //et "chims" la liste des caracxteristique par defaut
      _tab = newTab;
      titreCourant = _tab.etiquete;
    });
  }

//fonction permettant de generer le tableau
  genererTabMatiere() {
    // contruction des controleur et de la table de composition
    List<DataRow> lignes = [];
    controleur.clear();

    comps.forEach((key, value) {
      // contoleurs de la matiere premiere de nom (key)
      controleur.addAll({
        key: {
          "valeurMoyenne":
              TextEditingController(text: comps[key]!.valeurMoyenne.toString()),
          "ecartAcceptable": TextEditingController(
              text: comps[key]!.ecartAcceptable.toString()),
        }
      });
      lignes.add(DataRow(cells: [
        // nom de matiere premiere

        DataCell(Text(key)),
        // controleur pour la quantité
        DataCell(TextField(
          controller: controleur[key]!["valeurMoyenne"],
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
        )),

        // controleur pour le prix unitaire
        DataCell(TextField(
          controller: controleur[key]!["ecartAcceptable"],
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
        )),
      ]));
    });

    if (lignes.isNotEmpty) {
      return DataTable(
          headingTextStyle:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          headingRowColor:
              MaterialStateProperty.resolveWith((states) => primaryColor()),
          dataRowColor:
              MaterialStateProperty.resolveWith((states) => thirtyColorBlur()),
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('recommandé')),
            DataColumn(label: Text('ecart acceptable')),
          ],
          rows: lignes);
    }
    return null;
  }

  Widget contentwidget(BuildContext context) {
    if (comps.isEmpty) {
      return const Text("la table est innexistante");
    }

    if (!isInit) {
      tabRecommandations = genererTabMatiere();

      if (tabRecommandations == null) {
        return const Text("un probleme au niveau des composition est survenu");
      }
      isInit = true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: tabRecommandations ?? const Text("data")),
    );
  }

// fonction permettant de construire la liste des des boutons d'actions du menu
  List<Widget> listActionButton(BuildContext context) {
    List<Widget> list = [
      PopupMenuButton<String>(
        tooltip: "options",
        onSelected: (value) {},
        itemBuilder: (context) => [
          PopupMenuItem(
              padding: const EdgeInsets.all(0),
              child: ListTile(
                leading: Icon(
                  Icons.edit,
                  color: primaryColorBlur(),
                ),
                title: const Text("modifier l'étiquete"),
                onTap: () async {
                  Map? r = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            content: FormTabRecommandView(titre: titreCourant));
                      });

                  if (r != null) {
                    setState(() {
                      titreCourant = r["etiquete"];
                      isChanged = true;
                    });
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              )),
        ],
      )
    ];
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
            tooltip: "sauvegarder les modicafications",
          ));
    }
    return list;
  }

  // fonction permettant de sauvegarder les modificaion possible et d'actualiser la vue
  saveAnyCorrect() async {
    //on actualise le titre
    _tab.etiquete = titreCourant;

    sq.Database? database = await SqliteDatabase.db.database;
    if (database != null) {
      try {
        database.execute(
            "UPDATE table_recommandation set etiquete='${_tab.etiquete}' where id=${_tab.id}");
      } catch (e) {
        print("object");
      }
    }
    for (String key in controleur.keys) {
      if (controleur[key]!["ecartAcceptable"]!.text != "") {
        if (database != null) {
          try {
            database.execute(
                "UPDATE recommandation_car_chi set ecartAcceptable='${controleur[key]!["ecartAcceptable"]!.text}' where idTabRecommandation=${_tab.id} and idCarChi=${comps[key]!.idCarChi}");
            // ignore: empty_catches
          } catch (e) {}
        }
      }
      if (controleur[key]!["valeurMoyenne"]!.text != "") {
        if (database != null) {
          try {
            database.execute(
                "UPDATE recommandation_car_chi set valeurMoyenne='${controleur[key]!["valeurMoyenne"]!.text}' where idTabRecommandation=${_tab.id} and idCarChi=${comps[key]!.idCarChi}");
            // ignore: empty_catches
          } catch (e) {}
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // on recupere le tableau de composition suivi des routes
    TabRecommandation? newTab =
        ModalRoute.of(context)!.settings.arguments as TabRecommandation?;

    if (newTab != null && newTab.id != _tab.id) {
      actualiser(newTab);
    }

    if (!isLoad) {
      updateComps();
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
          title: Text(titreCourant),
          backgroundColor: primaryColor(),
        ),
        body: contentwidget(context));
  }
}
