import 'package:flutter/material.dart';
import '../models/tab_composition.dart';
import '../utils.dart';
import '../views/FormTabCompPage.dart';

import 'TabCompDetailPage.dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import '../repository/SqliteDatabase.dart';

class ListTabCompositionPage extends StatefulWidget {
  static String url = "/listing/tabComposition";
  const ListTabCompositionPage({Key? key}) : super(key: key);

  @override
  State<ListTabCompositionPage> createState() => _ListTabCompositionPageState();
}

class _ListTabCompositionPageState extends State<ListTabCompositionPage> {
  List<TabComposition> tabs = [];
  bool loadTabs = false;
  updateTabs() async {
    sq.Database? database = await SqliteDatabase.db.database;

    if (database != null) {
      var list = database.select("""
        SELECT * FROM table_composition order by dateModification DESC; 
      """);
      setState(() {
        tabs.clear();
        loadTabs = true;
        for (var row in list) {
          tabs.add(TabComposition(
              id: row['id'],
              titre: row['titre'],
              prixSub: row['prixSub'],
              dateCreation: DateTime.parse(row['dateCreation']),
              dateModification: DateTime.parse(row['dateModification'])));
        }
      });
    }
  }

  ListTile getTabCompSimple(BuildContext context, TabComposition e) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      title: Text(e.titre.toString()),
      subtitle: Text(getTime(e.dateModification)),
      leading: CircleAvatar(
          backgroundColor: primaryColor(),
          child: Text(
            e.titre[0],
            style: const TextStyle(color: Colors.white),
          )),
      onTap: () async {
        await Navigator.pushNamed(context, TabCompDetailPage.url, arguments: e);
        updateTabs();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loadTabs) {
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
              tooltip: "retourner en arriere",
            );
          },
        ),
        title: const Text("Tables de composition"),
        backgroundColor: primaryColor(),
      ),
      body: tabs.isEmpty
          ? const Center(
              child: Text(
                "Aucune composition existante",
                textAlign: TextAlign.center,
              ),
            )
          : listTabWidget(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryDarkColor(),
        onPressed: () {
          showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(content: FormTabCompView(titre: null));
              }).then((value) {
            if (value != null && value == true) {
              return updateTabs();
            }
            return "null";
          }).then((value) {
            if (value != "null") {
              Navigator.pushNamed(
                context,
                TabCompDetailPage.url,
                arguments: tabs[0],
              ).then(
                (value) => updateTabs(),
              );
            }
          });
        },
        tooltip: 'ajouter une nouvelle table de composition',
        child: const Icon(Icons.post_add),
      ),
    );
  }

  //constructioin de la liste des tableau de composition ( les vues minimales )
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
                        "DELETE FROM table_composition WHERE id=${tabs[index].id}");
                    database.execute(
                        "DELETE FROM composition_mt WHERE idTabComp=${tabs[index].id}");
                    tabs.remove(tabs[index]);
                    // ignore: empty_catches
                    updateTabs();
                  } catch (e) {
                    //print("object");
                  }
                }
              },
              child: Card(
                child: getTabCompSimple(context, tabs[index]),
              ));
        });
  }
}
