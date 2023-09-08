import 'package:flutter/material.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //generate code for language switch
import 'dart:io';
import 'package:path/path.dart';
//import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:direction/draw_graph/models/feature.dart';
import 'package:direction/classParameterSet.dart';
import 'dart:math';
import 'package:intl/date_symbol_data_local.dart';
//initializeDateFormatting('fr_FR', null).then((_) => runMyCode());

//Fields is a singleton class that gives any widget access to the fields
class Fields {
  static final Fields _singleton = Fields._internal();

  static List<ParameterSet> _fieldList = [
    //ParameterSet(fieldName: 'Default Field'),
    //ParameterSet(fieldName: 'f2'),
  ];

  static int _selectedField = 0;
  static Future<bool> _dbread = _fromDisk();

  //for reading and writing to database so we can store values locally
  //
  // Increment this version when you need to change the schema.
  //TODO if you change the schema, you must implement the _onVersionChange method! Note that fromMap() is relatively robust to changes and will simply ignore, the error comes when writing records to a table that has a wrong schema
  // note at the moment this will simply create a new database with the increased number in the name.
  // note that the old database is not deleted.
  static final databaseVersion = 3;
  //
  //// This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "parameterset.sqlite.db";

  static final tableName = 'ParameterSet';
  // Only allow a single open connection to the database.
  static Future<Database> _database = _initDatabase();
  //static bool _init = false;
  static Future<Database> get database async {
    return _database;
  }

  // open the database
  static Future<Database> _initDatabase() async {
    print('opening database');
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print('Connecting to database in ${documentsDirectory.path}');
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onDowngrade: _onVersionChange,
      onUpgrade: _onVersionChange,
    );
  }

  // SQL string to create the database
  static Future _onCreate(Database db, int version) async {
    print("creating new database with version $version");
    await db.execute('''
              CREATE TABLE "$tableName" (
                ${ParameterSet.sqlSchema()}
              )
              ''');
  }

  static bool _versionChange = false;
  static Future<void> _onVersionChange(
      Database db, int oldVersion, int newVersion) async {
    print("Converting database");
    _versionChange = true;
    //_fromDisk();
    //read data from old version (this is robust against missing entries)
    //if (await _dbread) {
    //delete table
    //   await db.execute("DROP TABLE IF EXISTS $tableName"); //removes the table
    //todo create new table
    /* await db.execute('''
              CREATE TABLE "$tableName" (
                ${ParameterSet.sqlSchema()}
              )
              ''');
      //write new data
      toDisk();
    }*/
  }

  static Future toDisk() async {
    print("writing data to disk");
    Database db = await database;
    if (await _dbread) {
      // for safety let's not try to update but simply replace all entries
      db.delete(tableName); //deletes all rows in the table
      //delete table
      if (Fields._versionChange) {
        //delete table
        await db.execute("DROP TABLE IF EXISTS $tableName"); //removes the table
        //todo create new table
        await db.execute('''
              CREATE TABLE "$tableName" (
                ${ParameterSet.sqlSchema()}
              )
              ''');
      }

      var batch = db.batch();
      //todo what if table is not empty?
      _fieldList.forEach((e) async {
        //note db.insert return an int for the unique id
        batch.insert(
            tableName, e.toMap()); //inserts if not exists, otherwise replaces
      });
      await batch.commit(
        noResult: true,
      );
    }
  }

  static Future<bool> _fromDisk() async {
    print("reading data from disk");
    //throw away any records
    _fieldList.clear();
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      //where: 'id = ?',
    );
    print("retrieving fields");
    maps.forEach((element) {
      print("database retrieved field number ${_fieldList.length}");
      _fieldList.insert(_fieldList.length, ParameterSet.fromMap(element));
    });
    return (true);
  }

  static Future<bool> fromDisk() async {
    return _dbread;
  }

  static ParameterSet getCurrentField() {
    return _fieldList[_selectedField];
  }

  static void setCurrentField(int i) {
    if (i < 0) i = 0;
    if (i > _fieldList.length - 1) i = _fieldList.length - 1;
    _selectedField = i;
    //toDisk();//this is called many times when sliding a slider
  }

  static int length() {
    return _fieldList.length;
  }

  static void insert(String fn) {
    if (fn.isEmpty) fn = "unnamed field";
    bool found = false;
    _fieldList.forEach((fe) => {if (fe.fieldName == fn) found = true});
    if (found) {
      //print(fn);
      insert(fn + '+');
    } else {
      //unique name
      _fieldList.insert(0, ParameterSet(fieldName: fn));
    }
    toDisk();
  }

  static ParameterSet removeAt(int i) {
    final removed = _fieldList.removeAt(i);
    toDisk();
    return removed;
  }

  static ParameterSet at(int i) {
    return _fieldList[i];
  }

  static Future<bool> runSimulations() async {
    var pr = List<Future<bool>>.generate(
        _fieldList.length, (index) => _fieldList[index].runSimulation());
    int allRan = 0;
    for (var e in pr) {
      bool ran = await e;
      ++allRan;
    }
    return (allRan == _fieldList.length); //any simulation ran.
  }

  static List<Feature> getFeatures(int n) {
    final gst = Fields.getStartTime();
    final get = Fields.getEndTime();
    final dt = SimulationModel.pdt;
    final gn = (get - gst) ~/ dt;
    var rl = (List<Feature>.generate(
        _fieldList.length,
        (index) => Feature(
              data: List<double>.generate(gn, (index) => 0.0),
              color: _fieldList[index].getColor(),
              title: _fieldList[index].fieldName,
            )));

    //data copy
    for (int j = 0; j < _fieldList.length; ++j) {
      final double st =
          _fieldList[j].getSimulationParameter(ParameterNames.istart);
      final int aj = max(0.0, st - gst).floor() ~/ dt;
      final d = _fieldList[j].getFeatureData(n);
      final mv = d.reduce(max);
      //print("Field: $j aj:$aj gn:$gn");
      for (int i = 0; i < gn - aj && i < d.length; i++) {
        rl[j].data[aj + i] = d[i] / mv;
      }
    }

    return (rl);
  }

  static double getStartTime() {
    double st = 1e9;
    _fieldList.forEach((element) {
      st = min(element.getSimulationParameter(ParameterNames.istart), st);
    });
    return st;
  }

  static double getEndTime() {
    double st = 0;
    _fieldList.forEach((element) {
      st = max(
          element.getSimulationParameter(ParameterNames.istart) +
              element.getSimulationParameter(ParameterNames.iend),
          st);
    });
    return st + 1;
  }

  //static _monthFormater=DateFormat.MMM(locale);
  static List<String> getFeaturesX(BuildContext context) {
    final gst = Fields.getStartTime();
    final get = Fields.getEndTime();
    final dt = SimulationModel.pdt;
    final gn = (get - gst) ~/ dt;
    var r = List<String>.generate(gn, (index) => '');

    var labs = [
      AppLocalizations.of(context)!.jan,
      AppLocalizations.of(context)!.mar,
      AppLocalizations.of(context)!.may,
      AppLocalizations.of(context)!.jul,
      AppLocalizations.of(context)!.sep,
      AppLocalizations.of(context)!.nov,
    ];
    for (int j = 1 + 15 ~/ dt; j < r.length; ++j) {
      int ct = (gst + j * dt).ceil();
      if (((ct - 15) % 61) < dt) {
        int pos = ct ~/ 61;
        r[j] = labs[pos]; //ct.toString();
      }
    }
    return r;
  }

  static List<String> getFeaturesY(int n) {
    final rl = (List<double>.generate(
        _fieldList.length, (index) => _fieldList[index].getDataMax(n)));
    double mv = rl.reduce(max);
    //print('getFeaturesY max is $mv');
    int r = mv < 4
        ? 2
        : mv < 10
            ? 1
            : 0;

    return [
      (0.25 * mv).toStringAsFixed(r),
      (0.5 * mv).toStringAsFixed(r),
      (0.75 * mv).toStringAsFixed(r),
      mv.toStringAsFixed(r)
    ];
  }

  static String getPredictions(BuildContext context) {
    //final _dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
    String formatDates(DateTime d) {
      return ("${d.day}/${d.month}/${d.year}");
    }

    String r = "";
    for (var e in _fieldList) {
      r += AppLocalizations.of(context)!.yieldPrediction(e.fieldName,
          ParameterNames.potentialYield.unit(context), e.getDataMax(0).toInt());
      //"Field '${e.fieldName}' has a predicted yield of ${e.getDataMax(0).toInt()} ${ParameterNames.potentialYield.unit(context)}.\n";
      int od = e.nextIrrigationDate().toInt();
      if (od > 0) {
        int oa = e.nextIrrigationAmount().toInt();
        DateTime irrdate =
            DateUtils.dateOnly(DateTime.now().add(Duration(days: od)));
        r += AppLocalizations.of(context)!.messageIrrigationAdvice(oa,
            formatDates(irrdate), ParameterNames.cumIrrigation.unit(context));
        //"You need to irrigate $oa ${ParameterNames.cumIrrigation.unit(context)} around the ${irrdate.toLocal()}.\n";
      } else {
        r += AppLocalizations.of(context)!
            .messageNoIrrigationNeeded; //"No irrigation needed in the foreseeable future.\n";
      }
      r += "\n";
    }

    return (r);
  }

  factory Fields() {
    return _singleton;
  }

  Fields._internal();
}
