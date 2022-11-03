import 'package:flutter/material.dart';
import 'package:kimgop/utils.dart';
import 'package:kimgop/views/FormTabRecommandPage..dart';

import '../models/tab_recommanation.dart';
import 'TabRecommandationDetail.dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import 'package:kimgop/repository/SqliteDatabase.dart';

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
      var list = database.select("select * from table_recommandation");
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
              icon: Icon(Icons.arrow_back_ios_new,color: secondaryColor()),
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
              child: Text("Aucunes tables de recommandations existantes"))
          : listTabWidget(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryDarkColor(),
        onPressed: () async {
          bool? r = await showDialog<bool?>(
              context: context,
              builder: (context) {
                return AlertDialog(content: FormTabRecommandView(titre: null)) ;
              });
          if (r != null) {
            if (r) {
              updateTabs();
            }
          }
        },
        tooltip: 'Ajouter une nouvelle table de recommandation',
        child: const Icon(Icons.add),
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
      onTap: () async {
        await Navigator.pushNamed(context, TabRecommandationDetailPage.url,
            arguments: e);
        updateTabs();
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

                    tabs.remove(tabs[index]);
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
