import 'package:flutter/material.dart';
import '../utils.dart';
import '../views/FormTabRecommandPage..dart';

import '../models/tab_recommanation.dart';
import 'TabRecommandationDetail.dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import '../repository/SqliteDatabase.dart';

class ListTabRecommandationPage extends StatefulWidget {
  static String url = "/listing/tabRecommandation";
  const ListTabRecommandationPage({Key? key}) : super(key: key);

  @override
  State<ListTabRecommandationPage> createState() =>
      _ListTabRecommandationPageState();
}

class _ListTabRecommandationPageState extends State<ListTabRecommandationPage> {
  bool loadtabs = false;
  List<TabRecommandation> tabs = [];

  updateTabs() async {
    sq.Database? database = await SqliteDatabase.db.database;
    if (database != null) {
      var list = database.select(
          "select * from table_recommandation as tb order by tb.id DESC");
      setState(() {
        loadtabs = true;
        tabs.clear();
        for (var row in list) {
          tabs.add(TabRecommandation(id: row['id'], etiquete: row['etiquete']));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loadtabs) {
      updateTabs();
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
              tooltip: "Retourner en arriere",
            );
          },
        ),
        title: const Text("Tables de Recommandation"),
        backgroundColor: primaryColor(),
      ),
      body: tabs.isEmpty
          ? const Center(
              child: Text(
                "Aucune récommandation existante",
                textAlign: TextAlign.center,
              ),
            )
          : listTabWidget(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryDarkColor(),
        onPressed: () {
          showDialog<bool?>(
              context: context,
              builder: (context) {
                return AlertDialog(content: FormTabRecommandView(titre: null));
              }).then((value) {
            if (value != null && value == true) {
              return updateTabs();
            }
            return "null";
          }).then(
            (value) {
              if (value != "null") {
                Navigator.pushNamed(
                  context,
                  TabRecommandationDetailPage.url,
                  arguments: tabs[0],
                ).then((value) => updateTabs());
              }
            },
          );
        },
        tooltip: 'Ajouter une nouvelle table de recommandation',
        child: const Icon(Icons.assignment_add),
      ),
    );
  }

  ListTile getTabRecommandationSimple(
      BuildContext context, TabRecommandation e) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
      title: Text(e.etiquete.toString()),
      leading: CircleAvatar(
          backgroundColor: primaryColor(),
          child: Text(
            e.etiquete[0],
            style: const TextStyle(color: Colors.white),
          )),
      onTap: () {
        Navigator.pushNamed(context, TabRecommandationDetailPage.url,
                arguments: e)
            .then((value) => updateTabs());
      },
    );
  }

  //construction de la liste des tableau de Recommandation ( les vues minimales )
  ListView listTabWidget(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: tabs.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
              background: Container(
                color: secondaryColor(),
              ),
              key: Key("$index-${DateTime.now().microsecondsSinceEpoch}"),
              onDismissed: (direction) async {
                sq.Database? database = await SqliteDatabase.db.database;
                if (database != null) {
                  try {
                    database.execute(
                        "DELETE FROM table_recommandation WHERE id=${tabs[index].id}");
                    database.execute(
                        "DELETE FROM recommandation_car_chi WHERE idTabRecommandation=${tabs[index].id}");
                    updateTabs();
                    // ignore: empty_catches
                  } catch (e) {}
                }
              },
              child: Card(
                child: getTabRecommandationSimple(context, tabs[index]),
              ));
        });
  }
}
