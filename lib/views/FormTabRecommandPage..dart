import 'package:flutter/material.dart';
import '../utils.dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import 'package:kimgop/repository/SqliteDatabase.dart';

class FormTabRecommandView extends StatefulWidget {
  String? titre;
  FormTabRecommandView({Key? key, required this.titre}) : super(key: key);
  @override
  State<FormTabRecommandView> createState() => _FormTabRecommandViewState();
}

class _FormTabRecommandViewState extends State<FormTabRecommandView> {
  late TextEditingController controleurTitre =
      TextEditingController(text: widget.titre ?? "");
  // methode permettant de retourner une repose a la vue appellant
  response() {
    Map result = {
      "etiquete": controleurTitre.text,
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
        padding: const EdgeInsets.fromLTRB(25, 50, 25, 50),
        child: Center(
          child: Wrap(
            children: [
              TextField(
                controller: controleurTitre,
                decoration: const InputDecoration(
                  labelText: 'etiquete',
                ),
                style: TextStyle(color: primaryColor()),
              ),
              errorState == 1
                  ? const Text("L'étiquete est existant, choisissez en un autre",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12))
                  : errorState == 2
                      ? const Text("L'étiquete est invalide",
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
                                    "INSERT INTO recommandation_car_chi (idCarChi, idTabRecommandation) "
                                    "SELECT cc.id, ccc.id "
                                    "FROM car_chimique as cc, table_recommandation as ccc "
                                    "WHERE ccc.etiquete = '${controleurTitre.text}';");
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context, true);
                              } catch (e) {
                                errorState == 1;
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
