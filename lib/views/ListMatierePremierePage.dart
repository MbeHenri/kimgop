import 'package:flutter/material.dart';
import 'package:kimgop/models/matiere_premiere_model.dart';
import 'package:kimgop/utils.dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import 'package:kimgop/repository/SqliteDatabase.dart';

class ListMatierePremierePage extends StatefulWidget {
  static String url = "/details/mp";
  const ListMatierePremierePage({Key? key}) : super(key: key);

  @override
  State<ListMatierePremierePage> createState() =>
      _ListMatierePremierePageState();
}

class _ListMatierePremierePageState extends State<ListMatierePremierePage> {
  List<MatierePremiere> tabs = [];

  bool actualised = false;

  updateList() async {
    sq.Database? database = await SqliteDatabase.db.database;

    if (database != null) {
      var list = database.select("""
        SELECT cc.id, cc.nom, cc.abreviation, cc.isDefault FROM matiere_premiere as cc; 
      """);
      setState(() {
        tabs.clear();
        actualised = true;
        for (var element in list) {
          tabs.add(MatierePremiere(
              nom: element["nom"],
              id: element["id"],
              abreviation: element['abreviation'],
              isDefault: element['isDefault']));
        }
        //tabs.addAll(list.toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!actualised) {
      updateList();
    }
    return Scaffold(
      appBar: AppBar(
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
        title: const Text("Matières premières"),
        backgroundColor: primaryColor(),
      ),
      body: tabs.isEmpty
          ? const Center(
              child: Text("aucunes matieres premieres n'as été retrouvées"))
          : listMatiere(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = (await showDialog<bool>(
              context: context,
              builder: ((context) {
                return const AlertDialog(
                    content: formMatierePremiere(val: null));
              })));

          if (result != null && result) {
            //on actualisera la liste des matieres premieres
            updateList();
          }
        },
        tooltip: 'ajouter une nouvelle matiere premiere',
        backgroundColor: secondaryDarkColor(),
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  ListView listMatiere() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: tabs.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
              key: Key("$index-${DateTime.now().microsecondsSinceEpoch}"),
              onDismissed: (direction) async {
                sq.Database? database = await SqliteDatabase.db.database;
                if (database != null) {
                  database.execute(
                      "DELETE FROM matiere_premiere WHERE id=${tabs[index].id}");
                }
                tabs.remove(tabs[index]);
              },
              child: Card(
                child: ListTile(
                  onTap: () async {
                    Map? result = (await showDialog<Map>(
                        context: context,
                        builder: ((context) {
                          return AlertDialog(
                              content: formMatierePremiere(val: tabs[index]));
                        })));

                    if (result != null) {
                      setState(() {
                        tabs[index].nom = result["nom"];
                        tabs[index].abreviation = result["abreviation"];
                        tabs[index].isDefault = result["isDefault"];
                      });
                    }
                  },
                  subtitle: Text(tabs[index].abreviation ?? ""),
                  title: Text(
                    tabs[index].nom,
                    style: TextStyle(
                        fontWeight: tabs[index].isDefault == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: tabs[index].isDefault == 1
                            ? primaryColor()
                            : Colors.black),
                  ),
                ),
              ));
        });
  }
}

// ignore: camel_case_types
class formMatierePremiere extends StatefulWidget {
  final MatierePremiere? val;
  const formMatierePremiere({Key? key, required this.val}) : super(key: key);

  @override
  State<formMatierePremiere> createState() => _formMatierePremiereState();
}

// ignore: camel_case_types
class _formMatierePremiereState extends State<formMatierePremiere> {
  // ignore: non_constant_identifier_names
  late TextEditingController controleur_nom =
      TextEditingController(text: widget.val != null ? widget.val!.nom : "");
  // ignore: non_constant_identifier_names
  late TextEditingController controleur_abreviation = TextEditingController(
      text: widget.val != null ? widget.val!.abreviation : "");

  bool isdefault = true;
  bool isload = false;

  //variable d'erreur indiquant si une erreur ou nom est parvenu
  int errorState = 0;

  @override
  void dispose() {
    controleur_abreviation.dispose();
    controleur_nom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isdefault &&
        widget.val != null &&
        widget.val!.isDefault == 0 &&
        !isload) {
      setState(() {
        isdefault = false;
        isload = true;
      });
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Form(
          child: Wrap(
            children: [
              TextFormField(
                controller: controleur_nom,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                ),
                style: TextStyle(color: primaryColor()),
              ),
              errorState == 1
                  ? const Text("Nom existant, choisissez un autre",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12))
                  : errorState == 2
                      ? const Text("Nom invalide",
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 12))
                      : const SizedBox(height: 40),
              TextFormField(
                controller: controleur_abreviation,
                decoration: InputDecoration(
                  fillColor: primaryColor(),
                  labelText: 'Abréviation',
                ),
                style: TextStyle(color: primaryColor()),
              ),
              const SizedBox(height: 60),
              SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(" Matiere première par défaut ?"),
                  value: isdefault,
                  activeColor: secondaryColor(),
                  onChanged: ((value) {
                    setState(() {
                      isdefault = value;
                    });
                  })),
              const SizedBox(height: 70),
              Row(
                children: [
                  TextButton(
                      onPressed: () async {
                        if (controleur_nom.text != "") {
                          var result = {
                            "nom": controleur_nom.text,
                            "abreviation": controleur_abreviation.text,
                            "isDefault": isdefault ? 1 : 0
                          };
                          sq.Database? database =
                              await SqliteDatabase.db.database;
                          if (widget.val != null) {
                            try {
                              database?.execute(
                                  "UPDATE matiere_premiere SET nom='${result["nom"]}', abreviation='${result["abreviation"]}', isDefault=${result["isDefault"]} "
                                  "WHERE id=${widget.val?.id}");
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context, result);
                              // ignore: empty_catches
                            } catch (e) {
                              setState(() {
                                errorState = 1;
                              });
                            }
                          } else {
                            try {
                              database?.execute(
                                  "INSERT INTO `matiere_premiere` (nom, abreviation, isDefault) VALUES ('${result["nom"]}', '${result["abreviation"]}', ${result["isDefault"]}) ;");
                              database?.execute(
                                  "INSERT INTO contenu_chimique (idMtP, idCar) "
                                  "SELECT ccc.id,cc.id "
                                  "FROM car_chimique as cc, matiere_premiere as ccc "
                                  "WHERE ccc.nom = '${result["nom"]}';"
                                  "INSERT INTO composition_mt (idTabComp, idMtP) "
                                  "SELECT ccc.id, cc.id "
                                  "FROM matiere_premiere as cc, table_composition as ccc "
                                  "WHERE cc.nom = '${result["nom"]}';");
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context, true);
                              // ignore: empty_catches
                            } catch (e) {
                              //espace de gestion des retours visuels
                              setState(() {
                                errorState = 1;
                              });
                            }
                          }
                        } else {
                          setState(() {
                            errorState = 2;
                          });
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(primaryColor())),
                      child: const Text(
                        "valider",
                        style: TextStyle(color: Colors.white),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              primaryColorBlur())),
                      child: const Text(
                        "annuler",
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              )
            ],
          ),
        ));
  }
}
