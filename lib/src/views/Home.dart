// ignore: file_names
import 'package:flutter/material.dart';
import '../models/tab_composition.dart';
import '../utils.dart';
import '../views/ParameterPage.dart';
import '../views/ListCarChimiquePage.dart';
import '../views/ListMatierePremierePage.dart';
import '../views/TabAlimentationPage.dart';
import '../views/TabCompDetailPage.dart';

import 'FormTabCompPage.dart';
import 'ListTabCompositionPage.dart';
import 'ListTabRecommandation.dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import '../repository/SqliteDatabase.dart';

class HomePage extends StatefulWidget {
  static const String url = '/';
  HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<TabComposition> _recents = [];

  bool loadResult = false;
  updateRecent() async {
    sq.Database? database = await SqliteDatabase.db.database;

    if (database != null) {
      var list = database.select("""
        SELECT * FROM table_composition order by dateModification DESC LIMIT 5; 
      """);
      setState(() {
        _recents.clear();
        loadResult = true;
        for (var row in list) {
          _recents.add(TabComposition(
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
        updateRecent();
      },
    );
  }

  // contruction des widgets enfants
  Widget _childrenWidget(context) {
    List<Widget> list = [
      Row(
        children: [
          const Expanded(
            child: Text(
              "Tables de compositions récentes",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Icon(
            Icons.calendar_today,
            color: secondaryColor(),
          ),
        ],
      ),
    ];
    if (_recents.isNotEmpty) {
      list.add(Container(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _recents.map((recent) {
                return getTabCompSimple(context, recent);
              }).toList())));

      list.add(
        TextButton.icon(
          onPressed: () async {
            await Navigator.pushNamed(context, ListTabCompositionPage.url);
            updateRecent();
          },
          icon: const Icon(Icons.keyboard_double_arrow_right_outlined),
          label: const Text(
            "Voir plus",
          ),
        ),
      );
    } else {
      list.add(
        TextButton.icon(
          onPressed: null,
          icon: const Icon(Icons.pix_outlined),
          label: const Text(
            "Vide",
          ),
        ),
      );
    }

    return Container(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: list));
  }

  @override
  Widget build(BuildContext context) {
    if (!loadResult) {
      updateRecent();
    }
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () async {
                Scaffold.of(context).openDrawer();
              },
              tooltip: "barre de navigation",
            );
          },
        ),
        title: const Image(image: AssetImage("assets/index_brand.png")),
        backgroundColor: primaryColor(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
        child: _childrenWidget(context),
      ),
      drawer: navigation(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryDarkColor(),
        onPressed: () async {
          showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(content: FormTabCompView(titre: null));
              }).then((value) {
            if (value != null && value == true) {
              return updateRecent();
            }
            return "null";
          }).then((value) {
            if (value != "null") {
              Navigator.pushNamed(
                context,
                TabCompDetailPage.url,
                arguments: _recents[0],
              ).then(
                (value) => updateRecent(),
              );
            }
          });
        },
        tooltip: 'ajouter une nouvelle table de composition',
        child: const Icon(Icons.post_add),
      ),
    );
  }

// fonction permettant de creer la vue du menu de navigation apres le clic
  Drawer navigation(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/index.jpeg"),
                      fit: BoxFit.cover)),
              child: null),
          ListTile(
            leading: Icon(
              Icons.table_chart,
              color: thirtyColor(),
            ),
            title: const Text('Tableaux de composition'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, ListTabCompositionPage.url);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.recommend_outlined,
              color: thirtyColor(),
            ),
            title: const Text('Tables de recommandation'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, ListTabRecommandationPage.url);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.table_view,
              color: thirtyColor(),
            ),
            title: const Text("Tableau d'alimentation"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, TabAlimentationPage.url);
            },
          ),
          ListTile(
            leading: Icon(Icons.compost_outlined, color: thirtyColor()),
            title: const Text('Matieres Premieres'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, ListMatierePremierePage.url);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.science,
              color: thirtyColor(),
            ),
            title: const Text('Elements chimiques'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, ListCarChimiquePage.url);
            },
          ),
          ListTile(
              leading: Icon(Icons.settings, color: thirtyColor()),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, ParameterPage.url);
              }),
        ],
      ),
    );
  }
}
