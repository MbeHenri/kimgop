// ignore: file_names
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import '../repository/SqliteDatabase.dart';

import '../utils.dart';

class ListCarChimiquePage extends StatefulWidget {
  static String url = "/details/mc";
  const ListCarChimiquePage({Key? key}) : super(key: key);

  @override
  State<ListCarChimiquePage> createState() => _ListCarChimiquePageState();
}

//liste des caracteristique etulisable
class _ListCarChimiquePageState extends State<ListCarChimiquePage> {
  List<Map> tabs = [];
  bool actualised = false;

  updateList() async {
    sq.Database? database = await SqliteDatabase.db.database;

    if (database != null) {
      var list = database.select("""
        SELECT cc.id, cc.nom, cc.abreviation, cc.isDefault, u.nom as unite FROM car_chimique as cc , unite as u WHERE cc.idUnite = u.id; 
      """);
      setState(() {
        tabs.clear();
        actualised = true;
        for (var element in list) {
          tabs.add({
            "nom": element["nom"],
            'id': element["id"],
            'unite': element['unite'],
            'abreviation': element['abreviation'],
            'isDefault': element['isDefault']
          });
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
        title: const Text("Elements chimiques"),
        backgroundColor: primaryColor(),
      ),
      body: tabs.isEmpty
          ? const Center(
              child: Text(
                "Aucun élemennt existant",
                textAlign: TextAlign.center,
              ),
            )
          : listCar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // on ouvre une modale de formulaire permettant d'ajouter une nouvelle caracteristique
          bool? result = (await showDialog<bool>(
              context: context,
              builder: ((context) {
                return const AlertDialog(content: formCarChimique(val: null));
              })));

          if (result != null && result) {
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

  ListView listCar() {
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
                      "DELETE FROM car_chimique WHERE id=${tabs[index]["id"]}");

                  database.execute(
                      "DELETE FROM contenu_chimique WHERE idCar=${tabs[index]["id"]}");

                  database.execute(
                      "DELETE FROM recommandation_car_chi WHERE idCarChi=${tabs[index]["id"]}");

                  updateList();
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
                              content: formCarChimique(val: tabs[index]));
                        })));

                    if (result != null) {
                      setState(() {
                        tabs[index]["nom"] = result["nom"];
                        tabs[index]["abreviation"] = result["abreviation"];
                        tabs[index]["isDefault"] = result["isDefault"];
                        tabs[index]["unite"] = result["unite"];
                      });
                    }
                  },
                  subtitle: Text(
                      "${tabs[index]["abreviation"]} (${tabs[index]["unite"]})",
                      style: TextStyle(
                          color: tabs[index]["isDefault"] == 1
                              ? thirtyColor()
                              : null)),
                  title: Text(
                    tabs[index]["nom"],
                    style: TextStyle(
                        fontWeight: tabs[index]["isDefault"] == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: tabs[index]["isDefault"] == 1
                            ? primaryColor()
                            : Colors.black),
                  ),
                ),
              ));
        });
  }
}

// ignore: camel_case_types
class formCarChimique extends StatefulWidget {
  final Map? val;
  const formCarChimique({Key? key, required this.val}) : super(key: key);

  @override
  State<formCarChimique> createState() => _formCarChimiqueState();
}

// ignore: camel_case_types
class _formCarChimiqueState extends State<formCarChimique> {
  // controleur du nom
  // ignore: non_constant_identifier_names
  late TextEditingController controleur_nom =
      TextEditingController(text: widget.val != null ? widget.val!["nom"] : "");

  //controleur de l'abreviation
  // ignore: non_constant_identifier_names
  late TextEditingController controleur_abreviation = TextEditingController(
      text: widget.val != null ? widget.val!["abreviation"] : "");

  // valeur booleen permettant de definir si oui ou nom la caracteristique est definie par defaut
  bool isdefault = true;

  // valeur traduisant l'unite de la caracteristique
  // la valeur moins -1 indiquera qu'on a trouvee et sera l'indice de la premiere unite
  int idUnite = -1;

  bool isload = false;

  //variable d'erreur indiquant si une erreur ou nom est parvenu
  int errorState = 0;

  @override
  void dispose() {
    controleur_abreviation.dispose();
    controleur_nom.dispose();
    super.dispose();
  }

  //listes d'unites
  List<Map> unites = [];
  load() async {
    sq.Database? database = await SqliteDatabase.db.database;

    if (database != null) {
      var list = database.select('select * from unite');
      setState(() {
        unites.clear();
        for (var element in list) {
          unites.add({'id': element['id'], 'nom': element['nom']});
        }
        if (widget.val != null) {
          idUnite = unites.firstWhere(
              (element) => element["nom"] == widget.val!["unite"])["id"];
        } else {
          idUnite = unites[0]["id"];
        }
      });
    }
  }

  DropdownButton<int>? listWidgetUnite() {
    if (unites.isEmpty) {
      return null;
    }
    List<DropdownMenuItem<int>> list = [];
    for (var e in unites) {
      list.add(DropdownMenuItem<int>(
        value: e["id"],
        child: Container(
          padding: const EdgeInsets.fromLTRB(9, 0, 0, 0),
          child: Text(e["nom"]),
        ),
      ));
    }
    return DropdownButton<int>(
      items: list,
      value: idUnite,
      onChanged: (value) {
        setState(() {
          idUnite = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isdefault &&
        widget.val != null &&
        widget.val!["isDefault"] == 0 &&
        !isload) {
      setState(() {
        isdefault = false;
        isload = true;
      });
    }

    if (idUnite == -1) {
      load();
    } else {
      if (idUnite == -1 && unites.isNotEmpty) {
        setState(() {
          idUnite = unites[0]["id"];
        });
      }
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Form(
          child: Wrap(
            children: [
              //formulaire du nom
              TextFormField(
                controller: controleur_nom,
                decoration: const InputDecoration(
                  labelText: 'nom',
                ),
                style: TextStyle(color: primaryColor()),
              ),
              const SizedBox(height: 40),

              //formulaire de l'abreviation
              TextFormField(
                controller: controleur_abreviation,
                decoration: InputDecoration(
                  fillColor: primaryColor(),
                  labelText: 'abreviation',
                ),
                style: TextStyle(color: primaryColor()),
              ),
              errorState == 1
                  ? const Text(
                      "Le nom ou l'abréviation a déja été utilisé, choisissez en d'autre",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12))
                  : errorState == 2
                      ? const Text("Le nom ou l'abréviation est invalide",
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 12))
                      : const SizedBox(height: 50),

              //switch decrivant le caractere par defaut
              SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Axe d'analyse courant ?"),
                  value: isdefault,
                  activeColor: secondaryColor(),
                  onChanged: ((value) {
                    setState(() {
                      isdefault = value;
                    });
                  })),
              const SizedBox(height: 40),

              // dropdown d'unités
              Row(
                children: [
                  const Text(
                    "Unité :",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 20),
                  listWidgetUnite() ?? const Text("data"),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  //bouton permettant de valider
                  TextButton(
                      onPressed: () async {
                        if (controleur_nom.text != "" &&
                            controleur_abreviation.text != "" &&
                            idUnite != -1) {
                          //idUnite utile au referencement de l'unite choisi , on actualisera ou insera la caracteristique chimique
                          // en fonction de "val" passé en parametres
                          sq.Database? database =
                              await SqliteDatabase.db.database;
                          var result = {
                            "nom": controleur_nom.text,
                            "abreviation": controleur_abreviation.text,
                            "isDefault": isdefault ? 1 : 0,
                            "unite": unites.firstWhere(
                                (element) => element["id"] == idUnite)['nom'],
                            "idUnite": idUnite
                          };
                          if (widget.val != null) {
                            try {
                              database?.execute(
                                  "UPDATE car_chimique SET nom='${result["nom"]}', abreviation='${result["abreviation"]}' , idUnite =$idUnite, isDefault=${result["isDefault"]} "
                                  "WHERE id=${widget.val?['id']}");
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
                                  "INSERT INTO `car_chimique` (nom, abreviation, idCarParent, isDefault, idUnite) VALUES ('${result["nom"]}', '${result["abreviation"]}', NULL, $idUnite, ${result["isDefault"]});");
                              database?.execute(
                                  "INSERT INTO contenu_chimique (idMtP, idCar) "
                                  "SELECT ccc.id,cc.id "
                                  "FROM car_chimique as cc, matiere_premiere as ccc "
                                  "WHERE cc.nom = '${result["nom"]}';"
                                  "INSERT INTO recommandation_car_chi (idCarChi, idTabRecommandation)"
                                  "SELECT cc.id, ccc.id "
                                  "FROM car_chimique as cc, table_recommandation as ccc "
                                  "WHERE cc.nom = '${result["nom"]}';");
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context, true);
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
