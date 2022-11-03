// ignore: file_names
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteDatabase {
  SqliteDatabase._();
  static final SqliteDatabase db = SqliteDatabase._();
  static Database? _database;

  //fonction de recuperation de la base de données
  Future<Database?> get database async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "bg.db");
    if (_database == null) {
      File file = File(path);
      if (file.existsSync()) {
        _database = sqlite3.open(path);
      } else {
        _database = await init(path);
      }
    }
    return _database;
  }

  Future<Database> init(String path) async {
    //on recupere le repertoire de l'application et on y met la base de données

    Database db = sqlite3.open(path);
    db.execute('''
CREATE TABLE `unite` (
  `id` int(255) NOT NULL ,
  `nom` varchar(10) NOT NULL unique, 
  primary key(id) 
) ;

INSERT INTO `unite` (`id`, `nom`) VALUES
(1, 'kcal'),
(2, '%');

CREATE TABLE `car_chimique` (
  `id` integer PRIMARY KEY ,
  `nom` varchar(100) NOT NULL unique,
  `abreviation` varchar(15) NOT NULL unique ,
  `idCarParent` int(11) DEFAULT NULL,
  `isDefault` tinyint(1) NOT NULL DEFAULT 1,
  `idUnite` int(11) DEFAULT NULL, 
  CONSTRAINT `car_chimique_ibfk_1` FOREIGN KEY (`idUnite`) REFERENCES `unite` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ;

INSERT INTO `car_chimique` (`id`, `nom`, `abreviation`, `idCarParent`, `isDefault`, `idUnite`) VALUES
(1, 'thréonine', 'THREO', NULL, 1, 2),
(3, 'lysine', 'lys', NULL, 1, 2),
(4, 'méthionine', 'meth', NULL, 1, 2),
(5, 'méthionine + cystine', 'meth + cys', NULL, 1, 2),
(6, 'tryptophane', 'tryp', NULL, 1, 2),
(7, 'calcium', 'ca', NULL, 1, 2),
(8, 'potassium', 'p', NULL, 1, 2),
(9, 'magnésium', 'mg', NULL, 1, 2),
(12, 'Énergie Métabolisable adulte', 'EMA adulte', NULL, 1, 1),
(13, 'Énergie Métabolisable jeune', 'EMA jeune', NULL, 1, 1);

CREATE TABLE `table_recommandation` (
  `id` integer PRIMARY KEY,
  `etiquete` int(255) NOT NULL unique
);

CREATE TABLE `table_composition` (
  `id` integer PRIMARY KEY,
  `titre` varchar(150) NOT NULL unique,
  `prixSub` double DEFAULT 0,
  `dateCreation` datetime NOT NULL,
  `dateModification` datetime NOT NULL
);

CREATE TABLE `matiere_premiere` (
  `id` integer primary key,
  `nom` varchar(100) NOT NULL unique,
  `abreviation` varchar(15) DEFAULT NULL,
  `isDefault` tinyint(1) NOT NULL DEFAULT 1
) ;

INSERT INTO `matiere_premiere` (`id`, `nom`, `abreviation`, `isDefault`) VALUES
(1, 'Blé', NULL, 1),
(3, 'Mais', NULL, 1),
(4, 'riz paddy', NULL, 1),
(5, 'son de blé', NULL, 1),
(6, 'tourteau de soja 50', NULL, 1),
(7, 'tourteau de arachide', NULL, 1),
(8, 'tourteau de coton', NULL, 1);


CREATE TABLE `composition_mt` (
  `idMtP` integer NOT NULL  ,
  `idTabComp` integer NOT NULL ,
  `quantite` double NOT NULL DEFAULT 0,
  `pu` double NOT NULL DEFAULT 0,
  primary key (idMtP, idTabComp),
  CONSTRAINT `composition_mt_ibfk_1` FOREIGN KEY (`idMtP`) REFERENCES `matiere_premiere` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `composition_mt_ibfk_2` FOREIGN KEY (`idTabComp`) REFERENCES `table_composition` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ;

CREATE TABLE `contenu_chimique` (
  `idMtP` integer NOT NULL,
  `idCar` integer NOT NULL,
  `valeur` double NOT NULL DEFAULT 0,
  primary key (idMtP, idCar),
  CONSTRAINT `contenu_chimique_ibfk_1` FOREIGN KEY (`idMtP`) REFERENCES `matiere_premiere` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `contenu_chimique_ibfk_2` FOREIGN KEY (`idCar`) REFERENCES `car_chimique` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ;

INSERT INTO `contenu_chimique` (`idMtP`, `idCar`, `valeur`) VALUES
(1, 1, 0.39),
(1, 3, 0.37),
(1, 4, 0.22),
(1, 5, 0.54),
(1, 6, 0.15),
(1, 7, 0.07),
(1, 8, 0.46),
(1, 9, 0.14),
(1, 12, 3470),
(1, 13, 3370),
(3, 1, 0.36),
(3, 3, 0.28),
(3, 4, 0.22),
(3, 5, 0.44),
(3, 6, 0.07),
(3, 7, 0.01),
(3, 8, 0.38),
(3, 9, 0.13),
(3, 12, 3430),
(3, 13, 3350),
(4, 1, 0.3),
(4, 3, 0.3),
(4, 4, 0.17),
(4, 5, 0.38),
(4, 6, 0.1),
(4, 7, 0.05),
(4, 8, 0.34),
(4, 9, 0.14),
(4, 12, 3160),
(4, 13, 3160),
(5, 1, 0.68),
(5, 3, 0.7),
(5, 4, 0.26),
(5, 5, 0.63),
(5, 6, 0.31),
(5, 7, 6.67),
(5, 8, 1.38),
(5, 9, 0.46),
(5, 12, 1740),
(5, 13, 1740),
(6, 1, 2.14),
(6, 3, 3.47),
(6, 4, 0.75),
(6, 5, 1.63),
(6, 6, 0.74),
(6, 7, 0.31),
(6, 8, 2.5),
(6, 9, 0.32),
(6, 12, 2670),
(6, 13, 2670),
(7, 1, 1.46),
(7, 3, 1.87),
(7, 4, 0.54),
(7, 5, 1.3),
(7, 6, 0.54),
(7, 7, 0.18),
(7, 8, 1.26),
(7, 9, 0.33),
(7, 12, 2910),
(7, 13, 2910),
(8, 1, 1.71),
(8, 3, 1.98),
(8, 4, 0.65),
(8, 5, 1.36),
(8, 6, 0.54),
(8, 7, 0.22),
(8, 8, 1.37),
(8, 9, 0.55),
(8, 12, 2110),
(8, 13, 2110);

CREATE TABLE `recommandation_car_chi` (
  `idTabRecommandation` integer NOT NULL,
  `idCarChi` integer NOT NULL,
  `valeurMoyenne` double NOT NULL default 0,
  `ecartAcceptable` double NOT NULL default 0,
  primary key (idTabRecommandation, idCarChi),
  CONSTRAINT `recommandation_car_chi_ibfk_1` FOREIGN KEY (`idTabRecommandation`) REFERENCES `table_recommandation` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recommandation_car_chi_ibfk_2` FOREIGN KEY (`idCarChi`) REFERENCES `car_chimique` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ;

CREATE TABLE `systeme` (
  `id` integer NOT NULL primary key,
  `idTabRecommandUse` integer NULL,
  CONSTRAINT `systeme_ibfk_1` FOREIGN KEY (`idTabRecommandUse`) REFERENCES `table_recommandation` (`id`) ON DELETE set null ON UPDATE CASCADE
) ;

INSERT INTO `systeme` (`id`, `idTabRecommandUse`) VALUES
(1, null);

''');
    return db;
  }

  Future<void> close() async {
    _database?.dispose();
    _database = null;
  }
}
