import 'package:flutter/material.dart';
import '../utils.dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import 'package:kimgop/repository/SqliteDatabase.dart';

class FormTabCompView extends StatefulWidget {
  String? titre;
  FormTabCompView({Key? key, required this.titre}) : super(key: key);
  @override
  State<FormTabCompView> createState() => _FormTabCompViewState();
}

class _FormTabCompViewState extends State<FormTabCompView> {
  late TextEditingController controleurTitre =
      TextEditingController(text: widget.titre ?? "");
  response() {
    Map result = {
      "titre": controleurTitre.text,
    };
    return result;
  }

  // variable d'indication d'erreur
  int errorState = 0;

  @override
  void dispose() {
    controleurTitre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Center(
          child: Wrap(
            children: [
              TextField(
                controller: controleurTitre,
                decoration: const InputDecoration(
                  labelText: 'titre',
                ),
                style: TextStyle(color: primaryColor()),
              ),
              errorState == 1
                  ? const Text(
                      "Le titre est existant, choisissez en un autre",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12))
                  : errorState == 2
                      ? const Text("Le titre est invalide",
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 12))
                      : const SizedBox(height: 70),
              Row(
                children: [
                  TextButton(
                      onPressed: () async {
                        //on renvoie le titre qui été entrer par l'utilisateur si la table existe déja
                        if (controleurTitre.text != "") {
                          if (widget.titre == null) {
                            sq.Database? database =
                                await SqliteDatabase.db.database;
                            if (database != null) {
                              try {
                                database.execute(
                                    "INSERT INTO table_composition (titre, dateCreation, dateModification) values ('${controleurTitre.text}','${DateTime.now()}','${DateTime.now()}');");
                                database.execute(
                                    "INSERT INTO composition_mt (idTabComp, idMtP) "
                                    "SELECT ccc.id, cc.id "
                                    "FROM matiere_premiere as cc, table_composition as ccc "
                                    "WHERE ccc.titre = '${controleurTitre.text}';");
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context, true);

                                // ignore: empty_catches
                              } catch (e) {
                                setState(() {
                                  errorState = 1;
                                });
                              }
                            }
                          } else {
                            Navigator.pop(context, response());
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
