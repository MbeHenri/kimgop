
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kimgop/models/composition_mt.dart';
import 'package:kimgop/models/tab_composition.dart';
import 'package:kimgop/utils.dart';
import 'package:kimgop/views/PdfPreviewPage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sqlite3/sqlite3.dart' as sq;
import 'package:kimgop/repository/SqliteDatabase.dart';

import 'FormTabCompPage.dart';

class TabCompDetailPage extends StatefulWidget {
  static String url = '/details/TabComp';

  const TabCompDetailPage({Key? key}) : super(key: key);

  @override
  State<TabCompDetailPage> createState() => _TabCompPageState();
}

class _TabCompPageState extends State<TabCompDetailPage> {
  // boolean permettant de verifier s'il ya une modification au niveau des controleurs
  bool isChanged = false;
  // fonction permettant de verifier que la vue a ete innitialiser
  bool isInit = false;

  late TabComposition _tab = TabComposition(
      id: -1,
      titre: "",
      prixSub: 0,
      dateCreation: DateTime.now(),
      dateModification: DateTime.now());

  // dictionnaire des compositions alimentaires des matieres premieres
  Map<String, CompositionMt> comps = <String, CompositionMt>{};

  Map<String, Map<String, TextEditingController>> controleur = {};

  @override
  void dispose() {
    controleurPrixSub.dispose();
    controleur.forEach((key, value) {
      value.forEach((kety, val) {
        val.dispose();
      });
    });
    super.dispose();
  }

  String titreCourant = "";
  late TextEditingController controleurPrixSub = TextEditingController();

  // dictionnaire de composition chimique
  Map<String, Map<String, double>> maps = {};

  //totaux
  Map<String, double> totaux = {};

  //prix moyen
  double prixMoyen = 0;

  //prix Total
  double prixTotal = 0;

  DataTable? tabChims;

  DataTable? tabMatieres;

  // etiquete de la table de recommandation
  String etiqueteRecommand = "";
  // dictionnaire de la table de recommandation
  Map<String, Map<String, double>> recommandation = {};

  Map<String, String> unites = {};

  bool load = false;
  updateAll() async {
    sq.Database? database = await SqliteDatabase.db.database;

    if (database != null) {
      try {
        // recuperation de la composition alimentaire suivant les matieres premieres par defaut
        var list1 = database.select("""
        SELECT cp.idMtP, cp.quantite, cp.pu, mp.nom
        FROM composition_mt as cp, matiere_premiere as mp
        WHERE cp.idTabComp = ${_tab.id} AND mp.id = cp.idMtP AND mp.isDefault = 1
      """);

        //chargement de la table alimentaire suivant les matieres premieres et elements chimiques  par defaut
        var list2 = database.select("""
        SELECT coc.valeur, cac.nom as nom_car, mp.nom as nom_mp
        FROM contenu_chimique as coc, matiere_premiere as mp, car_chimique as cac
        WHERE coc.idMtP = mp.id AND coc.idCar = cac.id AND mp.isDefault=1 AND cac.isDefault = 1
        ORDER BY cac.nom
      """);

        //chargement du nom de l'etiquete de la table de recomandation
        var list3 = database.select("""
        SELECT tr.etiquete
        FROM systeme as s, table_recommandation as tr
        WHERE s.idTabRecommandUse = tr.id;
      """);

        //chargement de la table de recommandation par defaut
        var list4 = database.select("""
        SELECT r.valeurMoyenne, r.ecartAcceptable, c.nom
        FROM systeme as s, recommandation_car_chi as r, car_chimique as c 
        WHERE s.idTabRecommandUse = r.idTabRecommandation AND c.id = r.idCarChi AND c.isDefault = 1
      """);

        //chargement des unites de caracteristiques chimiques par defaut
        var list5 = database.select("""
        SELECT u.nom as nom_unite, c.nom as nom_car   
        FROM car_chimique c , unite as u
        WHERE c.idUnite = u.id AND c.isDefault = 1;
      """);

        setState(() {
          load = true;
          comps.clear();
          for (var row in list1) {
            comps.addAll({
              row['nom']: CompositionMt(
                  idTabComp: _tab.id,
                  idMtP: row['idMtP'],
                  quantite: row['quantite'],
                  pu: row['pu'])
            });
          }
          String ch = "";
          maps.clear();
          for (var row in list2) {
            if (row['nom_car'] != ch) {
              ch = row['nom_car'];
              maps.addAll({ch: {}});
            }
            maps[ch]!.addAll({row['nom_mp']: row['valeur']});
          }

          for (var row in list3) {
            etiqueteRecommand = row['etiquete'];
          }
          recommandation.clear();
          for (var row in list4) {
            recommandation.addAll({
              row['nom']: {
                'valMoyenne': row['valeurMoyenne'],
                'ecartAcceptable': row['ecartAcceptable'],
              }
            });
          }
          unites.clear();
          for (var row in list5) {
            unites.addAll({row['nom_car']: row['nom_unite']});
          }
        });

        // ignore: empty_catches
      } catch (e) {}
    }
  }

  void actualiser(TabComposition newTab) {
    setState(() {
      //actualiser "comps" structure des compositions dependant des matieres premieres par default
      //et "chims" la liste des caracxteristique par defaut
      _tab = newTab;
      titreCourant = _tab.titre;
      controleurPrixSub = TextEditingController(text: _tab.prixSub.toString());
    });
  }

  genererTabChimique() {
    //construction du tableau d'analyse suivant les formules indiquées
    // en fonction des controleurs du tableau de matieres

    Map<String, double> chimsList = listeChimique();

    // construction de la vue
    List<DataRow> analyslist = [];
    chimsList.forEach((key, value) {
      analyslist.add(DataRow(cells: [
        DataCell(Text(key)),
        DataCell(Text(value.toString(),
            style: TextStyle(
                color: recommandation.isEmpty
                    ? colorAnyRecommand()
                    : colorRecommand(recommandation[key]!["valMoyenne"] ?? 0,
                        recommandation[key]!["ecartAcceptable"] ?? 0, value)))),
      ]));
    });
    if (analyslist.isNotEmpty) {
      return DataTable(
          headingTextStyle:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          headingRowColor:
              MaterialStateProperty.resolveWith((states) => primaryColor()),
          dataRowColor:
              MaterialStateProperty.resolveWith((states) => thirtyColorBlur()),
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('total'))
          ],
          rows: analyslist);
    }
    return null;
  }

// obtention du vecteur d'analyse suivant les caracteristiques chimiques
  Map<String, double> listeChimique() {
    Map<String, double> chimsList = {};
    maps.forEach((ech, valueMapCh) {
      chimsList.addAll({
        ech: 0,
      });

      double qt = 0;
      double tt = 0;
      valueMapCh.forEach((mp, value) {
        if (controleur[mp]!["quantite"]!.text != "") {
          double q = double.parse(controleur[mp]!["quantite"]!.text);

          if (q != 0) {
            qt += q;
            tt = tt + q * value;
          }
        }
      });
      if (qt != 0) {
        chimsList.addAll({
          ech: tt / qt,
        });
      }
    });
    return chimsList;
  }

  //fonction de generation du fichier pdf de la table de composition
  //avec la table de composition avec la table d'analyse
  generatePdf(context) async {
    var myTheme = pw.ThemeData.withFont(
      base: pw.Font.ttf(
          await rootBundle.load("assets/fonts/Helvetica/Helvetica.ttf")),
      bold: pw.Font.ttf(
          await rootBundle.load("assets/fonts/Helvetica/Helvetica-Bold.ttf")),
    );

    final pdf = pw.Document(
      theme: myTheme,
    );
    List<List<dynamic>> elementsTable = [
      [
        "Désignation",
        "Standard $etiqueteRecommand",
        "Formule $etiqueteRecommand"
      ]
    ];
    double qt = 0;
    controleur.forEach((key, value) {
      double q = 0;
      double p = 0;
      if (value["quantite"]!.text != "") {
        q = double.parse(value["quantite"]!.text);
      }
      if (value["pu"]!.text != "") {
        p = double.parse(value["pu"]!.text);
      }
      qt += q;
      elementsTable.add([
        "$key ($p F/kg)",
        "-",
        q,
      ]);
    });
    elementsTable.add(["Prix moyen (F/Kg)", "-", prixMoyen]);
    elementsTable.add(["Prix moyen par tonne (F)", "-", prixMoyen * qt]);
    elementsTable
        .add(["Prix suplémentaire (F/Kg)", "-", controleurPrixSub.text]);
    elementsTable.add(["Prix Total (F/Kg)", "-", prixTotal]);

    Map<String, double> chimsList = listeChimique();
    recommandation.forEach((key, value) {
      double min = (value["valMoyenne"] ?? 0) - (value["ecartAcceptable"] ?? 0);
      double max = (value["valMoyenne"] ?? 0) + (value["ecartAcceptable"] ?? 0);
      if (min < 0) {
        min = 0;
      }
      if (max < 0) {
        max = 0;
      }
      elementsTable.add([
        "$key (${unites[key]}/Kg)",
        "$min - $max",
        chimsList[key].toString(),
      ]);
    });
    var logo = pw.Image(
        pw.MemoryImage(
          (await rootBundle.load('assets/index_brand_3x.png'))
              .buffer
              .asUint8List(),
        ),
        width: 100);
    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => <pw.Widget>[
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Center(child: logo),
                    pw.Header(
                        text:
                            "Formule aliment $etiqueteRecommand".toUpperCase(),
                        textStyle: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ]),
              pw.Table.fromTextArray(data: elementsTable)
            ]));

    final flow = await pdf.save();
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PdfPreviewPage(titre: titreCourant, flow: flow)));
  }

  updatePrixMoyen() {
    double qt = 0;
    double pt = 0;
    controleur.forEach((key, value) {
      if (controleur[key]!["quantite"]!.text != "" &&
          controleur[key]!["pu"]!.text != "" &&
          totaux[key] as double != 0) {
        qt += double.parse(controleur[key]!["quantite"]!.text);
        pt += totaux[key] as double;
      }
    });
    prixMoyen = qt != 0 ? pt / qt : 0;
  }

  genererTabMatiere() {
    // contruction des controleur et de la table de composition
    List<DataRow> lignes = [];
    controleur.clear();
    totaux.clear();

    comps.forEach((key, value) {
      // contoleurs de la matiere premiere de nom (key)
      controleur.addAll({
        key: {
          "quantite": TextEditingController(text: value.quantite.toString()),
          "pu": TextEditingController(text: value.pu.toString()),
        }
      });
      totaux.addAll({
        key: controleur[key]!["pu"]!.text != "" &&
                controleur[key]!["quantite"]!.text != ""
            ? double.parse(controleur[key]!["pu"]!.text) *
                double.parse(controleur[key]!["quantite"]!.text)
            : 0
      });
      lignes.add(DataRow(cells: [
        // nom de matiere premiere

        DataCell(Text(key)),
        // controleur pour la quantité
        DataCell(TextField(
          controller: controleur[key]!["quantite"],
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
              totaux[key] = value != "" && controleur[key]!["pu"]!.text != ""
                  ? double.parse(value) *
                      double.parse(controleur[key]!["pu"]!.text)
                  : 0;
              updatePrixMoyen();
              prixTotal = prixMoyen +
                  (controleurPrixSub.text != ""
                      ? double.parse(controleurPrixSub.text)
                      : 0);
            });
          },
        )),

        // controleur pour le prix unitaire
        DataCell(TextField(
          controller: controleur[key]!["pu"],
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
              totaux[key] =
                  value != "" && controleur[key]!["quantite"]!.text != ""
                      ? double.parse(value) *
                          double.parse(controleur[key]!["quantite"]!.text)
                      : 0;
              updatePrixMoyen();
              prixTotal = prixMoyen +
                  (controleurPrixSub.text != ""
                      ? double.parse(controleurPrixSub.text)
                      : 0);
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
            DataColumn(label: Text('MP')),
            DataColumn(label: Text('quantités (kg)')),
            DataColumn(label: Text('PU (F/kg)')),
          ],
          rows: lignes);
    }
    return null;
  }

  Widget contentwidget(BuildContext context) {
    if (comps.isEmpty) {
      return Center(
          child: Container(
              padding: const EdgeInsets.all(10),
              child: const Text(
                  "Aucune matière premiere n'as été défini par défaut, veillez en definir",
                  style: TextStyle(fontWeight: FontWeight.bold))));
    }

    if (!isInit) {
      tabMatieres = genererTabMatiere();

      if (tabMatieres == null) {
        return Center(
            child: Container(
                padding: const EdgeInsets.all(10),
                child: const Text("Un probleme innattentu est survenu",
                    style: TextStyle(fontWeight: FontWeight.bold))));
      }
      isInit = true;
      updatePrixMoyen();
      prixTotal = prixMoyen +
          (controleurPrixSub.text != ""
              ? double.parse(controleurPrixSub.text)
              : 0);
    }
    List<DataRow> rowsTotaux = [];
    totaux.forEach((key, value) {
      rowsTotaux.add(DataRow(cells: [DataCell(Text("$value"))]));
    });

    List<Widget> list = [];
    list.addAll([
      Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
        child: Text(
          "Table de matieres premieres".toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              tabMatieres ?? const Text("data"),
              DataTable(
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => primaryColor()),
                  dataRowColor: MaterialStateProperty.resolveWith(
                      (states) => thirtyColorBlur()),
                  columns: const [
                    DataColumn(label: Text('TOTAL')),
                  ],
                  rows: rowsTotaux)
            ],
          )),
      const SizedBox(
        height: 10,
      ),
      SizedBox(
          child: ListTile(
              title: const Text(
                "Prix moyen (F/kg): ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(prixMoyen.toString()))),
      Container(
        padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
        child: SizedBox(
          width: 200,
          child: TextField(
            controller: controleurPrixSub,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(expReguliereReel())),
              TextInputFormatter.withFunction((oldValue, newValue) =>
                  newValue.copyWith(text: newValue.text.replaceAll(',', '.')))
            ],
            decoration: InputDecoration(
              fillColor: primaryColor(),
              labelText: 'prix supplémentaire (F/kg)',
            ),
            onChanged: (value) {
              setState(() {
                prixTotal = prixMoyen + (value != "" ? double.parse(value) : 0);
                isChanged = true;
              });
            },
          ),
        ),
      ),
      SizedBox(
          child: ListTile(
              title: const Text(
                "Prix Total (F/kg): ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(prixTotal.toString()))),
    ]);

    if (maps.isEmpty) {
      list.add(const Text(
          "Aucun axe d'analyse n'as été défini, veillez en definir"));
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list,
        ),
      );
    }

    tabChims = genererTabChimique();
    if (tabChims == null) {
      list.add(
        const Text("Un probleme innattentu est survenu"),
      );
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list,
        ),
      );
    }

    list.addAll([
      const SizedBox(
        height: 10,
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
        child: Text(
          "Table d'analyse".toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: tabChims ?? const Text("data"),
      ),
    ]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }

  List<Widget> listActionButton(BuildContext context) {
    List<Widget> list = [
      PopupMenuButton<String>(
        tooltip: "options",
        icon: Icon(Icons.list, color: secondaryColor()),
        onSelected: (value) {},
        itemBuilder: (context) => [
          PopupMenuItem(
              padding: const EdgeInsets.all(0),
              child: ListTile(
                leading: Icon(
                  Icons.edit,
                  color: primaryColorBlur(),
                ),
                title: const Text("Modifier le titre"),
                onTap: () async {
                  Map? r = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            content: FormTabCompView(titre: titreCourant));
                      });

                  if (r != null) {
                    setState(() {
                      titreCourant = r["titre"];
                      isChanged = true;
                    });
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              )),
          PopupMenuItem(
              padding: const EdgeInsets.all(0),
              child: ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Color.fromARGB(255, 155, 66, 60),
                ),
                title: const Text("Prévisualiser le document"),
                onTap: () {
                  Navigator.pop(context);
                  generatePdf(context);
                },
              ))
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

  //fonction de sauvegarde de l'etat des travaux
  saveAnyCorrect() async {
    bool ok = false;
    sq.Database? database = await SqliteDatabase.db.database;
    if (titreCourant != "" && titreCourant != _tab.titre) {
      //on actualise le titre
      _tab.titre = titreCourant;

      if (database != null) {
        try {
          database.execute("""
              UPDATE table_composition SET titre='${_tab.titre}' 
              WHERE id=${_tab.id};
          """);
          ok = true;
          // ignore: empty_catches
        } catch (e) {}
      }
    }

    if (controleurPrixSub.text != "" &&
        controleurPrixSub.text != _tab.prixSub.toString()) {
      //on actualise le prix supplementaire
      _tab.prixSub = double.parse(controleurPrixSub.text);
      if (database != null) {
        try {
          database.execute("""
            UPDATE table_composition SET prixSub='${_tab.prixSub}' 
            WHERE id=${_tab.id};
          """);
          ok = true;
          // ignore: empty_catches
        } catch (e) {}
      }
    }

    for (String key in controleur.keys) {
      if (controleur[key]!["quantite"]!.text != "" &&
          controleur[key]!["quantite"]!.text !=
              comps[key]!.quantite.toString()) {
        comps[key]!.quantite = double.parse(controleur[key]!["quantite"]!.text);
        if (database != null) {
          try {
            database.execute("""
              UPDATE composition_mt SET quantite=${controleur[key]!["quantite"]!.text} 
              WHERE idTabComp=${_tab.id} AND idMtP=${comps[key]!.idMtP};
            """);
            ok = true;
            // ignore: empty_catches
          } catch (e) {}
        }
      }
      if (controleur[key]!["pu"]!.text != "" &&
          controleur[key]!["pu"]!.text != comps[key]!.pu.toString()) {
        comps[key]!.pu = double.parse(controleur[key]!["pu"]!.text);

        if (database != null) {
          try {
            database.execute("""
              UPDATE composition_mt SET pu=${controleur[key]!["pu"]!.text} 
              WHERE idTabComp=${_tab.id} AND idMtP=${comps[key]!.idMtP};
            """);
            ok = true;
            // ignore: empty_catches
          } catch (e) {}
        }
      }
    }
    if (ok) {
      if (database != null) {
        try {
          database.execute("""
              UPDATE table_composition SET dateModification='${DateTime.now()}' 
              WHERE id=${_tab.id};
          """);
          ok = true;
          // ignore: empty_catches
        } catch (e) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // on recupere le tableau de composition suivi des routes
    TabComposition? newTab =
        ModalRoute.of(context)!.settings.arguments as TabComposition?;

    if (newTab != null && newTab.id != _tab.id) {
      actualiser(newTab);
    }

    if (!load) {
      updateAll();
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
