//import 'dart:typed_data';

//import 'dart:ffi';
//import 'dart:js_util';

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //generate code for language switch
import 'package:collection/collection.dart'; //contains sum on lists.
import 'package:direction/draw_graph/models/feature.dart';
import 'package:direction/classFields.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';

//import 'dart:convert';
import 'package:csv/csv.dart';

//import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

enum ParameterNames {
  SRL,
  potentialYield,
  iLA,
  istart, //doy planting date
  iend, //after how many days do we harvest

  fcThreshHold,
  cumIrrigation,
  autoIrrigateDuration,
  irrigationDripHoleRate,
  irrigationDripHoleDistance,
  irrigationDripLineDistance,
  doNotIrrigateTheLastXdays,
  scaleRain, // "reduce or increase expected rainfall
  scaleNfert
}

extension ParameterNamesExtension on ParameterNames {
  double min() {
    switch (this) {
      case ParameterNames.iend:
        return (1.0); //h
      case ParameterNames.autoIrrigateDuration:
        return (1.0); //h
      case ParameterNames.irrigationDripHoleRate:
        return (0.10); //l/hole/hour
      case ParameterNames.irrigationDripHoleDistance:
        return (10); //cm
      case ParameterNames.irrigationDripLineDistance:
        return (40); //cm
      default:
        return 0;
    }
  }

  double max() {
    switch (this) {
      case ParameterNames.SRL:
        return 60.0;
      case ParameterNames.potentialYield:
        return 80000;
      case ParameterNames.iLA:
        return 1000;
      case ParameterNames.istart:
        return 365;
      case ParameterNames.iend:
        return 365;
      case ParameterNames.fcThreshHold:
        return 100;
      case ParameterNames.autoIrrigateDuration:
        return (24.0); //h
      case ParameterNames.irrigationDripHoleRate:
        return (3.0); //l/hole/hour
      case ParameterNames.irrigationDripHoleDistance:
        return (100); //cm
      case ParameterNames.irrigationDripLineDistance:
        return (120); //cm
      case ParameterNames.doNotIrrigateTheLastXdays:
        return (365);
      case ParameterNames.scaleRain:
        return (150); //%
      case ParameterNames.scaleNfert:
        return (150); //%

      default:
        return 100000;
    }
  }

  double unitConv(BuildContext context) {
    switch (this) {
      case ParameterNames.potentialYield:
        final Locale appLocale = Localizations.localeOf(context);
        if (appLocale == Locale("th")) {
          return 1 / 6.25; //use kg/rai
        } else {
          return 1; //keep kg/ha
        }
      case ParameterNames.cumIrrigation:
        final Locale appLocale = Localizations.localeOf(context);
        if (appLocale == Locale("th")) {
          return 10 / 6.25; //mm to m3/ray
        } else {
          return 10; //mm to m3/ha
        }
      default:
        return 1;
    }
  }

  double defaultValue() {
    //make sure this is between min and max
    switch (this) {
      case ParameterNames.SRL:
        return 39;
      case ParameterNames.potentialYield:
        return 30000;
      case ParameterNames.iLA:
        return 100;
      case ParameterNames.istart:
        return 91;
      case ParameterNames.iend:
        return 270;
      case ParameterNames.autoIrrigateDuration:
        return 7.0; //h
      case ParameterNames.irrigationDripHoleRate:
        return 1.60; //l/hole/hour
      case ParameterNames.irrigationDripHoleDistance:
        return 30; //cm
      case ParameterNames.irrigationDripLineDistance:
        return 100; //cm
      case ParameterNames.doNotIrrigateTheLastXdays:
        return 60; //days, 2 month
      case ParameterNames.scaleRain:
        return 100; //% no scaling
      case ParameterNames.scaleNfert:
        return 100; //% no scaling
      default:
        return 0;
    }
  }

  String unit(BuildContext context) {
    switch (this) {
      case ParameterNames.SRL:
        return AppLocalizations.of(context)!.unitSRL;
      case ParameterNames.potentialYield:
        return AppLocalizations.of(context)!.unitYield;
      case ParameterNames.iLA:
        return AppLocalizations.of(context)!.unitLAI;
      case ParameterNames.istart:
        return AppLocalizations.of(context)!.unitTime;
      case ParameterNames.iend:
        return AppLocalizations.of(context)!.unitTime;
      case ParameterNames.fcThreshHold:
        return AppLocalizations.of(context)!.unitPercent;
      case ParameterNames.autoIrrigateDuration:
        return AppLocalizations.of(context)!.unithour; //h
      case ParameterNames.irrigationDripHoleRate:
        return AppLocalizations.of(context)!.unitliterperholeperhour; //h
      case ParameterNames.irrigationDripHoleDistance:
        return AppLocalizations.of(context)!.unitcm; //cm
      case ParameterNames.irrigationDripLineDistance:
        return AppLocalizations.of(context)!.unitcm; //cm
      case ParameterNames.doNotIrrigateTheLastXdays:
        return AppLocalizations.of(context)!.unitTime; //days
      case ParameterNames.scaleRain:
        return AppLocalizations.of(context)!.unitPercent; //%
      case ParameterNames.scaleNfert:
        return AppLocalizations.of(context)!.unitPercent; //%
      case ParameterNames.cumIrrigation:
        return AppLocalizations.of(context)!.unitIrrigation;
      default:
        return AppLocalizations.of(context)!.noUnit;
    }
  }

  String prettyName(BuildContext context) {
    switch (this) {
      case ParameterNames.SRL:
        return AppLocalizations.of(context)!.parameterNameSRL;
      case ParameterNames.potentialYield:
        return AppLocalizations.of(context)!.parameterNamePotentialYield;
      case ParameterNames.iLA:
        return AppLocalizations.of(context)!.parameterNameInitialLeafArea;
      case ParameterNames.istart:
        return AppLocalizations.of(context)!.parameterNameStartingTime;
      case ParameterNames.iend:
        return AppLocalizations.of(context)!.parameterNameEndingTime;
      case ParameterNames.fcThreshHold:
        return AppLocalizations.of(context)!.parameterNameFieldCapacity;
      case ParameterNames.autoIrrigateDuration:
        return AppLocalizations.of(context)!
            .parameterNameDurationOfIrrigation; //h
      case ParameterNames.irrigationDripHoleRate:
        return AppLocalizations.of(context)!
            .parameterNameDripRateOfSingleHole; //l/hole/hour
      case ParameterNames.irrigationDripHoleDistance:
        return AppLocalizations.of(context)!
            .parameterNameDistanceBetweenHoles; //cm
      case ParameterNames.irrigationDripLineDistance:
        return AppLocalizations.of(context)!
            .parameterNameDistaneBetweenRows; //cm
      case ParameterNames.doNotIrrigateTheLastXdays:
        return AppLocalizations.of(context)!
            .parameterNameStopIrrigationXdaysBeforeHarvest; //cm
      case ParameterNames.scaleRain:
        return AppLocalizations.of(context)!
            .parameterNameReduceOrIncreaseExpectedRainfall; //cm
      case ParameterNames.scaleNfert:
        return AppLocalizations.of(context)!
            .parameterNameReduceOrIncreaseFertilizationLevel; //cm

      default:
        return AppLocalizations.of(context)!.parameterNameDefault;
    }
  }

//unique column names for the sql database, without spaces dots and other special characters
//note that the enum.value.toString() method might contain dots and spaces
  String colName() {
    switch (this) {
      case ParameterNames.istart:
        return 'st';
      case ParameterNames.iend:
        return 'et';
      default:
        return this.toString().replaceAll(".", "");
    }
  }

  static int numberToShow({bool expert = true}) {
    if (expert) {
      return (8); //make sure this fits with reorder()
    } else {
      return (5); //make sure this fits with reorder()
    }
  }

  static ParameterNames reorder(int j) {
    //determines the order in the user entry page
    switch (j) {
      case 0:
        return ParameterNames.autoIrrigateDuration;
      case 1:
        return ParameterNames.irrigationDripHoleRate;
      case 2:
        return ParameterNames.irrigationDripHoleDistance;
      case 3:
        return ParameterNames.irrigationDripLineDistance;
      case 5:
        return ParameterNames.doNotIrrigateTheLastXdays;
      case 4:
        return ParameterNames.fcThreshHold;
      case 6:
        return ParameterNames.scaleRain;
      case 7:
        return ParameterNames.scaleNfert;
      default:
        return ParameterNames.istart;
    }
  }
}

class ParameterSet {
  static int _numberOfInstances = 0;
  final int id;
  String fieldName;

  //model parameters
  final _simPars = new Map<ParameterNames, double>();

  //drawing
  late Color _color;

  //
  static final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.purple,
  ];

  //simulator
  late SimulationModel _simulationModel;

  //constructor
  ParameterSet({required this.fieldName}) : this.id = _numberOfInstances {
    //make color unique.
    int ci = _numberOfInstances;
    while (ci >= _colors.length) ci -= _colors.length;
    _color = _colors[ci];
    //TODO check if this color is unique or present in fields, and otherwise choose another.
    //increment instance counter
    ++_numberOfInstances;
    //
    _simulationModel = SimulationModel(this);
  }

// //to and from map in order to store the parameters in a row of a table
// make sure both methods use same keys, in this case colName() is used.
// the constructor will work with an empty map in which case it constructs a default field with the name fieldxx
  ParameterSet.fromMap(Map<String, dynamic> map)
      : this.id = _numberOfInstances,
        fieldName = map['fn'] == null
            ? 'field' + _numberOfInstances.toString()
            : map['fn'] {
    if (map['col'] == null) {
      int ci = _numberOfInstances;
      while (ci >= _colors.length) ci -= _colors.length;
      _color = _colors[ci];
    } else {
      _color = new Color(map['col']).withOpacity(1);
    }
    ++_numberOfInstances;
    //load values
    map.forEach((key, value) {
      //map key to enum Parameternames and check the value is different from the default value.
      ParameterNames.values.forEach((pn) {
        if (pn.colName() == key && pn.defaultValue() != value) {
          //todo double comparison might easily fail.
          _simPars[pn] = value;
        }
      });
    });
    //instantiate model
    _simulationModel = SimulationModel(this);
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'fn': fieldName, 'col': _color.value};
    ParameterNames.values.forEach((element) {
      map[element.colName()] = _simPars[element] == null
          ? element.defaultValue()
          : _simPars[element];
    });
    return map;
  }

  // Delivers input for the sql schema that is used to read and write the map from the database
  static String sqlSchema() {
    //assert(Fields.databaseVersion == 14); //TODO should be compiletime check, not runtime check. All we want is that if this schema is updated, the version number is also updated.
    String schema = '''"id" INTEGER PRIMARY KEY,
                   "fn" TEXT NOT NULL,
                   "col" INTEGER NOT NULL''';
    ParameterNames.values.forEach((element) {
      schema += ''',"${element.colName()}" DOUBLE ''';
    });
    return schema;
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'ParameterSet{id: $id, field: $fieldName}';
  }

  // data
  List<List<double>> getSimulationResults() {
    return _simulationModel.getResultsTable();
  }

  // visualization
  List<double> getFeatureData(int n) {
    return _simulationModel.getResults(n);
  }

  Future<bool> runSimulation({bool readFromBundle = true}) async {
    bool r =
        await _simulationModel.loadWeatherData(readFromBundle: readFromBundle);
    if (r) {
      return _simulationModel.simulate();
    } else {
      return (false);
    }
  }

  double getDataMax(int n) {
    return _simulationModel.getResults(n).reduce(max);
  }

  List<double> getSimulationPrintTime() {
    return _simulationModel.getPrintTime();
  }

  double nextIrrigationDate() {
    var cur = _simulationModel.getDoy2(DateTime.now());
    var t = _simulationModel.getPrintTime();
    var irr = _simulationModel.getResults(2);
    var pirr = 0.0;
    for (var j = 0; j < t.length; ++j) {
      var lirr = irr[j] - pirr;
      var lt = t[j];
      if (lt > cur) {
        if (lirr > 1e-3) return lt - cur;
      } else {
        pirr = irr[j];
      }
    }
    return -1.0;
  }

  double nextIrrigationAmount() {
    var cur = _simulationModel.getDoy2(DateTime.now());
    var t = _simulationModel.getPrintTime();
    var irr = _simulationModel.getResults(2);
    var pirr = 0.0;
    for (var j = 0; j < t.length; ++j) {
      var lirr = irr[j] - pirr;
      var lt = t[j];
      if (lt > cur) {
        if (lirr > 1e-3) return lirr;
      } else {
        pirr = irr[j];
      }
    }
    return 0.0;
  }

  Color getColor() {
    return _color;
  }

  List<Color> getColors() {
    return _colors;
  }

  void setColor(Color c) {
    _color = c;
  }

  double getSimulationParameter(ParameterNames key) {
    final v = _simPars[key];
    if (v == null) {
      return key.defaultValue();
    } else {
      return v;
    }
  }

  void setSimulationParameter(ParameterNames key, double value) {
    if (_simPars[key] != value) {
      _simPars[key] = value;
      _simulationModel.parametersHaveChanged(); //
    }
    ;
  }

  int getNumberOfSimulationParameters() {
    return _simPars.length;
  }
}

class SimulationModel {
  ParameterSet _ps;
  final double _APPi = 0.80 *
      1.00; // Area per plant (row x interrow spacing) (m2); PC edited the value from 0.60*0.60 to 0.80*1.00 based on data from BRR2021-Y1.
  final int _nsl = 5; // number of soil layers
  //double _depth = 0.9; // soil depth in m
  late final double _lw = 0.9 / _nsl; //depth/_nsl;// thickness of a layer in m
  //double layers      = 0:(_nsl-1) * depth/_nsl;// soil layer positions
  late final double _lvol =
      _lw * _APPi; //depth*_APPi/_nsl;// volume of one soil layer
  // unit conversion factors
  //double s_day = 60 * 60 * 24;
  //double m_day = 60 * 24;
  //double m5_day = 12 * 24;
  final double _BD =
      1360; // soil bulk density in (kg/m3) # Burrirum 1.36, Ratchaburi 1.07 g.cm3
  //double raiInm2 = 1600; // area of one rai in m2

  double _cuttingDryMass = 75.4; //g
  double _leafAge = 75;
  double _SRL = 39.0; //m/g

  double _istart = 0;
  double _iend = 0;

  //double _igstart = 0;
  //double _igend = 0;
//todo needs to be based on planting date provided by user.then weather should start at right point
  double _itheta = 0.22;
  double _thm = 0.18; //drier todo make
  double _ths = 0.3; //field capacity, not saturation todo rename
  double _thr = 0.015;
  double _thg = 0.02;
  double _rateFlow = 1.3;

  double relTheta(double th) {
    return (lim((th - _thr) / (_ths - _thr)));
  } // relative theta on scale 0-1

  //double _drainageFactor = 0.0367;
  double _fcThreshHold = 0;
  double _autoIrrigate = 50;
  double _autoIrrigateTime = -1;
  double _autoIrrigationDuration = 1;
  bool _irrigateFromFile = false; //todo settings to switch
  double _stopIrrigation = 240.0;
  double _scaleRain = 1.0;
  double _scaleNfert = 1.0;

  //List<double> _irrigationDays = [0, 10, 100];
  //List<double> _irrigation = [20, 20, 20];

  static const int _printSize = 366; //51
  bool _hasRun = false;

  void parametersHaveChanged() {
    _hasRun = false;
  }

  List<double> _printTime = List.generate(_printSize, (index) => -1000.0);

  List<double> getPrintTime() {
    return _printTime;
  }

  List<List<double>> _results =
      List.generate(8, (index) => List.generate(_printSize, (index) => 0.0));

  //constructor
  SimulationModel(ParameterSet ps) : _ps = ps;

  //thai use other units then metric
  //will only convert them once the result is requested
  static double _convfact = 1;
  static double _convfact3 = 1;

  static setConversionFactors(BuildContext context) {
    _convfact = ParameterNames.potentialYield.unitConv(context);
    _convfact3 = ParameterNames.cumIrrigation.unitConv(context);
  }

  // helper functions
  List<double> multiplyLists(List<double> l1, List<double> l2) {
    var n = min(l1.length, l2.length);
    return (new List<double>.generate(n, (i) => l1[i] * l2[i]));
  }

  List<double> substractLists(List<double> l1, List<double> l2) {
    var n = min(l1.length, l2.length);
    return (new List<double>.generate(n, (i) => l1[i] - l2[i]));
  }

  List<double> multiplyListsWithConstant(List<double> l, double c) {
    return (new List<double>.generate(l.length, (i) => l[i] * c));
    //return(l.map( (number) => number *c));
  }

  double lim(double x, {double xl = 0, double xu = 1}) {
    if (x > xu) {
      return (xu);
    } else if (x < xl) {
      return (xl);
    } else {
      return x;
    }
  }

  double monod(double conc, {double Imax = 0.0, double Km = 1.0}) {
    double pc = max(0.0, conc);
    return (pc * Imax / (Km + pc));
  }

  double logistic(double x,
      {double x0 = 0.33, double xc = 100, double k = 0.2, double m = 0.85}) {
    return (x0 + (m - x0) / (1 + exp(-k * (x - xc))));
  }

  double getStress(double clab, double dm,
      {double low = -0.02, double high = -9999.9, bool swap = false}) {
    if (high < -9999.0) high = low + 0.01;
    final dm1 = max(dm, 0.001);
    final cc = clab / dm1;
    var rr = lim((cc - low) / (high - low));
    if (swap) rr = 1.0 - rr;
    return (rr);
  }

  double photoFixMean(double ppfd, double lai,
      {double kdf = -0.47,
      double Pn_max = 29.37,
      double phi = 0.05553,
      double k = 0.90516}) {
    double r = 0;
    int n = 30; //higher more precise, lower faster
    double b = 4 * k * Pn_max;
    for (int i = 0; i < n; ++i) {
      double kf = exp(kdf * lai * (i + 0.5) / n);
      double I = ppfd * kf;
      double x0 = phi * I;
      double x1 = x0 + Pn_max;
      double p = x1 - sqrt(x1 * x1 - b * x0);
      r += p;
    }
    r *= -12e-6 * 60 * 60 * 24 * kdf * _APPi * lai / n / (2 * k);
    return (r);
  }

  // reference: this is a dart rewrite of the hourlyET function of the water package in R
  // by Guillermo Federico Olmedo who References Allen 2005 ASCE
  // It implements Penman-Monteith Hourly formulation
  double hourlyET(
      final tempC,
      final radiation,
      final relativeHumidity,
      final wind,
      final doy,
      final latitude,
      final longitude,
      final elevation,
      final longZ,
      final height) {
    final hours = (doy % 1) * 24;
    final tempK = tempC + 273.16;

    final Rs = radiation * 3600 / 1e+06; // radiation mean Ra
    final P = 101.3 *
        pow((293 - 0.0065 * elevation) / 293,
            5.256); // cong thuc tinh ap suat khong khi o do cao elevation
    final psi = 0.000665 * P; // cong thuc tinh gamma

    final Delta = 2503 *
        exp((17.27 * tempC) / (tempC + 237.3)) /
        (pow(tempC + 237.3, 2)); // cong thuc tinh delta- cai hinh tam giac
    final eaSat = 0.61078 *
        exp((17.269 * tempC) /
            (tempC +
                237.3)); // cong thuc tinh ap suat hoi bao hoa tai nhiet do K
    final ea = (relativeHumidity / 100) * eaSat;

    final DPV = eaSat - ea;
    final dr = 1 + 0.033 * (cos(2 * pi * doy / 365.0)); //dr
    final delta = 0.409 *
        sin((2 * pi * doy / 365.0) -
            1.39); // cong thuc tinh delta nhung cai hinh cai moc
    final phi = latitude * (pi / 180);
    final b = 2.0 * pi * (doy - 81.0) / 364.0;

    final Sc = 0.1645 * sin(2 * b) - 0.1255 * cos(b) - 0.025 * sin(b);
    final hourAngle = (pi / 12) *
        ((hours +
                0.06667 * (longitude * pi / 180.0 - longZ * pi / 180.0) +
                Sc) -
            12.0); // w
    final w1 = hourAngle - ((pi) / 24);
    final w2 = hourAngle + ((pi) / 24);
    final hourAngleS = acos(-tan(phi) * tan(delta)); // Ws
    final w1c = (w1 < -hourAngleS)
        ? -hourAngleS
        : (w1 > hourAngleS)
            ? hourAngleS
            : (w1 > w2)
                ? w2
                : w1;
    final w2c = (w2 < -hourAngleS)
        ? -hourAngleS
        : (w2 > hourAngleS)
            ? hourAngleS
            : w2;

    final Beta =
        asin((sin(phi) * sin(delta) + cos(phi) * cos(delta) * cos(hourAngle)));

    final Ra = (Beta <= 0)
        ? 1e-45
        : ((12 / pi) * 4.92 * dr) *
            (((w2c - w1c) * sin(phi) * sin(delta)) +
                (cos(phi) * cos(delta) * (sin(w2) - sin(w1))));

    final Rso = (0.75 + 2e-05 * elevation) * Ra;

    final RsRso = (Rs / Rso <= 0.3)
        ? 0.0
        : (Rs / Rso >= 1)
            ? 1.0
            : Rs / Rso;
    final fcd = (1.35 * RsRso - 0.35 <= 0.05)
        ? 0.05
        : (1.35 * RsRso - 0.35 < 1)
            ? 1.35 * RsRso - 0.35
            : 1;

    final Rna = ((1 - 0.23) * Rs) -
        (2.042e-10 *
            fcd *
            (0.34 - 0.14 * sqrt(ea)) *
            pow(tempK, 4)); // cong thuc tinh Rn

    final Ghr = (Rna > 0)
        ? 0.04
        : 0.2; // G for hourly depend on Rna (or Rn in EThourly)

    final Gday = Rna * Ghr;
    final wind2 = wind * (4.87 / (log(67.8 * height - 5.42)));
    final windf = (radiation > 1e-6) ? 0.25 : 1.7;

    final EThourly = ((0.408 * Delta * (Rna - Gday)) +
            (psi * (66 / tempK) * wind2 * (DPV))) /
        (Delta + (psi * (1 + (windf * wind2))));

    return (EThourly);
  }

  double fSLA(ct) {
    return (logistic(ct, x0: 0.04, xc: 60, k: 0.1, m: 0.0264));
  }

  double intgrl(var s, var r, var t) {
    return (1);
  } //placeholder function

  // nutrients in the soil

  late final List<double> _NminR_l = new List<double>.generate(
      _nsl,
      (d) =>
          _scaleNfert *
          36 /
          (_lvol * _BD) /
          pow(d + 1, 2)); //todo highly _nsl dependent

  bool _zerodrain = true;

  List<double> ode2(final double ct, final List<double> y, List<double> wd) {
    int cnt = -1;
    final LDM = y[++cnt]; // Leaf Dry Mass (g)
    final SDM = y[++cnt]; // Stem Dry Mass (g)
    final RDM = y[++cnt]; // Root Dry Mass (g)
    final SRDM = y[++cnt]; // Sotrage Root Dry Mass (g)
    final LA = y[++cnt]; // Leaf Area (m2)

    final mDMl = y[++cnt]; //intgrl("mDMl", 0, "mGRl");
    //var mDMld = y[7];//intgrl("mDMld", 0, "mGRld");
    final mDMs = y[++cnt]; //intgrl("mDMs", cuttingDryMass, "mGRs");
    //final mDM = y[9];//intgrl("mDM", 0, "mGR");
    ++cnt; //final mDMsr = y[++cnt]; //intgrl("mDMsr", 0, "mGRsr");
    //final TR = intgrl("TR", 0, "RR"); // Total Respiration (g C)
    final Clab = y[++cnt]; // labile carbon pool
    ++cnt;
    final rlL = y.sublist(cnt, cnt += _nsl); //Root length per layer (m)
    //final RL = sumList(RL_l); // Root length (m)

    final nrtL = y.sublist(cnt, cnt += _nsl); //Root tips per layer
    final NRT = nrtL.sum; // Root tips
    final thetaL = y.sublist(
        cnt, cnt += _nsl); //volumetric soil water content for each layer
    //for (int i = 0; i < thetaL.length; ++i) {
    //Should not be necessary
    //if (thetaL[i] > _ths) thetaL[i] = _ths;
    //if (thetaL[i] < _thr) thetaL[i] = _thr;
    //}
    //final Ncont_l   = intgrl("Ncont",[4.83+35, 10.105, 16.05]*_lvol*BD,"NcontR");// N-content in a soil layer (mg);
    final ncontL = y.sublist(cnt, cnt += _nsl);
    final nuptL = y.sublist(cnt, cnt += _nsl);
    final Nupt = nuptL.sum;

    final TDM = LDM + SDM + RDM + SRDM + Clab; // Total Dry Mass (g)
    final cDm = 0.43; // carbon to dry matter ratio (g C/g DM)

    // temperature
    final leafTemp = wd[1]; //return ([rain, temp, ppfd, et0, irri])
    /*  fitted to El-Sharkawy-etal-1984-fig2 with adj R2 of 0.8709
    and divided by the max value of 27.24, which is slightly lower than our Pnmax
    (Intercept) d$temperature          d$x2
 -0.832097717   0.124485738  -0.002114081 */
    final TSphot = lim(-0.832097717 +
        0.124485738 * leafTemp -
        0.002114081 * pow(leafTemp, 2)); // todo temperature curve fitting

    final TSshoot = lim(-1.5 + 0.125 * leafTemp) * lim(7.4 - 0.2 * leafTemp);
    final TSroot = 1.0; // effect of temperature on root sink strength

// water uptake
    fKroot(th, rl) {
      final rth = relTheta(th);
      final kadj = min(1.0, pow(rth / 0.4, 1.5));
      final Ksr = 0.01;
      return (Ksr * kadj * rl);
    }

    final krootL =
        new List<double>.generate(_nsl, (i) => fKroot(thetaL[i], rlL[i]));
    final Kroot = max(1e-8, krootL.sum); //sums up all elements.
    final thEquiv =
        Kroot > 1e-8 ? (multiplyLists(thetaL, krootL)).sum / Kroot : thetaL[0];

    //water stress
    fWstress(minv, maxv, the) {
      final s = 1 / (maxv - minv);
      final i = -1 * minv * s;
      return (lim(i + s * relTheta(the)));
    }

    final WStrans = fWstress(0.05, 0.5,
        thEquiv); //*(1.0-fWstress(0.9, 1.0, thEquiv));//feddes like todo look at DSSAT
    final WSphot =
        fWstress(0.05, 0.3, thEquiv); //*(1.0-fWstress(0.9, 1.0, thEquiv));
    final WSshoot =
        fWstress(0.2, 0.55, thEquiv); //*(1.0-fWstress(0.9, 1.0, thEquiv));
    final WSroot = 1;
    final WSleafSenescence = 1.0 -
        fWstress(0.0, 0.2, thEquiv); // 0 for non, 1 for enhanced scenescence

    // water in soil
    //irrigation either not (rained), or from file, or auto.
    // file/auto should switch on current date?
    var irrigation = _irrigateFromFile
        ? wd[4]
        : 0.0; //return ([rain, temp, ppfd, et0, irri])
    //auto irrigation if necessary and not provided by file.
    //todo, switching maybe not 100% stable in numerical scheme. should be ok with rk4
    if (irrigation < 1e-6 &&
        _autoIrrigateTime < ct + _autoIrrigationDuration &&
        _stopIrrigation > ct &&
        _fcThreshHold > _thr &&
        thEquiv < _fcThreshHold) {
      _autoIrrigateTime = ct;
      //print("irrigating ${_ps.fieldName} at $ct _stopIrrigation:$_stopIrrigation");
    }
    if (ct < _autoIrrigateTime + _autoIrrigationDuration) {
      irrigation += _autoIrrigate;
    }

    final precipitation = _scaleRain * wd[0] +
        irrigation; //return ([rain, temp, ppfd, et0, irri]) (amount of the rain ?)

    // Transpiration
    final ET0reference = wd[3]; //return ([rain, temp, ppfd, et0, irri])
    final ETrainFactor = (precipitation > 0) ? 1 : 0; // todo smooth this
    final kdf = -0.47;
    final ll =
        exp(kdf * LA / _APPi); // fraction of light falling on soil surface
    final cropFactor = max(1 - ll * 0.8, ETrainFactor);
    final transpiration = cropFactor * ET0reference; //su thoat hoi nuoc
    final swfe = pow(relTheta(thetaL[0]), 2.5); //todo time since rain
    final actFactor = max(ll * swfe, ETrainFactor);
    final evaporation = actFactor * ET0reference; // su bay hoi

    final actualTranspiration = transpiration *
        WStrans; // uptake in liter/day per m2 (su thoat hoi nuoc qua be mat da hoac co the cua cay)
    final wuptrL =
        multiplyListsWithConstant(krootL, actualTranspiration / Kroot);
    //Wupt    = intgrl("Wupt",rep(0.,_nsl),"WuptR")     , # Water uptake (l)

    var drain = 0.0;
    var qFlow = List.generate(_nsl + 1, (index) => 0.0);
    qFlow[0] = (precipitation - evaporation) / (_lw * 1000.0);
    for (var i = 1; i < qFlow.length; ++i) {
      final thdown = (i < _nsl)
          ? thetaL[i]
          : (_zerodrain)
              ? thetaL[i - 1] + _thg
              : _thm;
      qFlow[i] +=
          (thetaL[i - 1] + _thg - thdown) * _rateFlow * (thetaL[i - 1] / _ths) +
              4.0 * max(thetaL[i - 1] - _ths, 0);
    }
    var dThetaDt = List.generate(
        _nsl, (i) => qFlow[i] - qFlow[i + 1] - wuptrL[i] / (_lw * 1000.0));
    for (var e in dThetaDt) {
      assert(!e.isNaN, print("dThetaDt: $dThetaDt qFlow: $qFlow"));
    }
    drain = qFlow[_nsl] * _lw * 1000; //back to mm

    // nutrient stress effects
    double fNSstress(double upt, double low, double high) {
      double rr = (upt - low) / (high - low);
      return lim(rr);
    }

    // nutrient concentrations in the plant
    final Nopt = 45 * LDM + 7 * SRDM + 20 * SDM + 20 * RDM;
    final NuptLimiter = 1.0 - fNSstress(Nupt, 2.0 * Nopt, 3.0 * Nopt);
    //nutrient uptake
    final nuptrL = new List<double>.generate(
        _nsl,
        (i) => monod(ncontL[i] * _BD / (1000 * thetaL[i]),
            //mg/kg * kg/m3 / l/m3=mg/l
            Imax: NuptLimiter * rlL[i] * 0.8,
            Km: 12.0 * 0.5));
    for (var e in nuptrL) {
      assert(!e.isNaN, print("ncont_l=$ncontL theta_l=$thetaL"));
    }

    final ncontrL = List.generate(_nsl, (index) => 0.0); //mg/kg/day
    for (var i = 0; i < _nsl; ++i) {
      ncontrL[i] = _NminR_l[i];
      ncontrL[i] -= nuptrL[i] / (_BD * _lvol); //mg/day/ (m3*kg/m3)
      final Nl = ncontL[i];
      final Nu = (i > 0) ? ncontL[i - 1] : -ncontL[i];
      //final Nd = (i < (_nsl - 1)) ? Ncont_l[i + 1] : -Ncont_l[i];//zero flux bottom
      final Nd = (i < (_nsl - 1)) ? ncontL[i + 1] : 0.0; //leaching
      // no diffusion, just mass flow with water.
      ncontrL[i] += qFlow[i] * (Nu + Nl) / 2.0 - qFlow[i + 1] * (Nl + Nd) / 2.0;
    }
    for (var e in ncontrL) {
      assert(!e.isNaN, print("ncont_l=$ncontL qFlow=$qFlow theta=$thetaL"));
    }

    //final NcontR_l =  substractLists(_NminR_l, NuptR_l); // change in N in soil (mg/day)
    final NSphot = (Nopt > 1e-3) ? fNSstress(Nupt, 0.7 * Nopt, Nopt) : 1.0;
    final NSshoot =
        (Nopt > 1e-3) ? fNSstress(Nupt, 0.7 * Nopt, 0.9 * Nopt) : 1.0;
    final NSroot =
        (Nopt > 1e-3) ? fNSstress(Nupt, 0.5 * Nopt, 0.7 * Nopt) : 1.0;
    //final NSsroot = 1.0;
    // 1 for fast leaf senescence when plant is stressed for N
    final NSleafSenescence =
        (Nopt > 1.0) ? 1.0 - fNSstress(Nupt, 0.8 * Nopt, Nopt) : 0.0;

    // sink strength
    final mGRl = logistic(ct, x0: 0.3, xc: 70, k: 0, m: 0.9);
    final mGRld = logistic(ct, x0: 0.0, xc: 70.0 + _leafAge, k: 0.1, m: -0.90);
    final mGRs = logistic(ct, x0: 0.2, xc: 95, k: 0.219, m: 1.87) +
        logistic(ct, x0: 0.0, xc: 209, k: 0.219, m: 1.87 - 0.84);
    final mGRr = 0.02 + (0.2 + exp(-0.8 * ct - 0.2)) * mGRl;
    final mGRsr = min(7.08, pow(max(0.0, (ct - 32.3) * 0.02176), 2));
    final mDMr = 0.02 * ct +
        1.25 +
        0.25 * ct -
        1.25 * exp(-0.8 * ct) * mGRl +
        (0.25 + exp(-0.8 * ct)) * mDMl;

    // carbon limitations
    final CSphot = getStress(Clab, TDM,
        low: 0.05, swap: true); //Lower photosynthesis when starche accumulates
    final CSshoota = getStress(Clab, TDM,
        low: -0.05); //do not allocat to shoot when starche levels are low
    final CSshootl =
        lim(5 - LA / _APPi); // do not allocate to shoot when LAI is high
    final CSshoot = CSshoota * CSshootl;
    final CSroot = getStress(Clab, TDM, low: -0.03);
    final CSsrootl = getStress(Clab, TDM, low: -0.0);
    final CSsrooth = getStress(Clab, TDM, low: 0.01, high: 0.20);
    final starchRealloc =
        getStress(Clab, TDM, low: -0.2, high: -0.1, swap: true) * -0.05 * SRDM;
    final CSsroot = CSsrootl + 2 * CSsrooth;
    final SFleaf = WSshoot * NSshoot * TSshoot * CSshootl;
    final SFstem = WSshoot *
        NSshoot *
        TSshoot *
        CSshoot; //todo are leaf and stem not coupled?
    final SFroot = WSroot * NSroot * TSroot * CSroot;
    final SFsroot = CSsroot;

    final CsinkL = cDm * mGRl * SFleaf; //*
    //((mDMl > 1 && ct > 500)
    //    ? LDM / mDMl
    //    : 1); //todo LDM includes dead leafs
    // todo mDMs and mDMr seem off?
    final CsinkS =
        cDm * mGRs * SFstem; //* ((mDMs > 30 && ct > 500) ? SDM / mDMs : 1);
    final CsinkR =
        cDm * mGRr * SFroot; //* ((mDMr > 1 && ct > 300) ? RDM / mDMr : 1);
    final CsinkSR = cDm * mGRsr * SFsroot -
        starchRealloc; // todo check this * ((mDMsr > 5) ? SRDM / mDMsr : 1);
    final Csink = CsinkL + CsinkS + CsinkR + CsinkSR;

    // biomass partitioning
    final a2l = CsinkL / max(1e-10, Csink);
    final a2s = CsinkS / max(1e-10, Csink);
    final a2r = CsinkR / max(1e-10, Csink);
    final a2sr = CsinkSR / max(1e-10, Csink);

    // carbon to growth
    final CFG = Csink; // carbon needed for growth (g C/day)
    // increase in plant dry Mass (g DM/day) not including labile carbon pool
    final IDM = Csink / cDm;

    //photosynthesis
    final PPFD = wd[2]; //return ([rain, temp, ppfd, et0, irri])
    final SFphot = min(min(TSphot, WSphot), min(NSphot, CSphot));
    final CFR = photoFixMean(PPFD, LA / _APPi, Pn_max: 29.37 * SFphot);

    final SDMR = a2s * IDM; // stem growth rate (g/day)
    final SRDMR = a2sr * IDM; // storage root growth rate (g/day)

    final SLA = fSLA(ct);
    // Leaf Senescence, note that this does not lead to reallocation here
    // todo leaf senescence is absolute, not less if plant is small. Can lead to rapid loss of LA.
    // note that this should have delays on LDM or LA instead of this.
    final LDRstress = WSleafSenescence * NSleafSenescence * LDM * -1.0;
    final LDRage = mGRld * ((mDMl > 0) ? LDM / mDMl : 1.0);
    assert(LDRstress <= 1e-6 && LDRage <= 1e-6,
        "LDRstress: $LDRstress LDRage: $LDRage");
    final LDRm = max(-LDM, LDRstress + LDRage);
    final LDRa = max(-LA, fSLA(max(0.0, ct - _leafAge)) * LDRm);
    final LAeR = SLA * a2l * IDM + LDRa; // Leaf Area expansion Rate (m2/day)
    final LDMR = a2l * IDM +
        LDRm; //+ mGRld; // leaf growth rate (g/day) - death rate (g/day)

    final RDMR = a2r * IDM; // fine root growth rate (g/day)
    final RLR = _SRL * RDMR;
    final rlrL = new List<double>.generate(_nsl, (i) => RLR * nrtL[i] / NRT);
    var ln0 = 0.0;
    final nrtrL = new List<double>.generate(_nsl, (i) => 0.0);
    for (var i = 0; i < _nsl; ++i) {
      final ln1 = rlrL[i];
      nrtrL[i] = ln1 * 60.0 + max(0, (ln0 - ln1 - 6.0 * _lw) * 10.0 / _lw);
      ln0 = ln1;
    }

    // respiration
    //final RR = 0.018 * RDM + 0.002 * SRDM + 0.018 * LDM + 0.002 * SDM;
    final mRR = 0.003 * RDM + 0.0002 * SRDM + 0.003 * LDM + 0.0002 * SDM;
    final gRR = 1.8 * RDMR + 0.2 * SRDMR + 1.8 * (LDMR - LDRm) + 0.4 * SDMR;
    final RR = mRR + gRR;

    // labile pool
    final ClabR = (CFR - CFG - RR) / cDm;

    // construct array of rates, make sure order is same as in y.
    cnt = -1;
    var YR = new List<double>.generate(9, (index) => 0.0);
    YR[++cnt] = LDMR;
    YR[++cnt] = SDMR;
    YR[++cnt] = RDMR;
    YR[++cnt] = SRDMR;
    YR[++cnt] = LAeR;

    YR[++cnt] = mGRl;
    YR[++cnt] = mGRs;
    YR[++cnt] = mGRsr.toDouble(); //pow returns num not sure how to avoid this
    YR[++cnt] = ClabR;

    YR = [...YR, ...rlrL, ...nrtrL, ...dThetaDt, ...ncontrL, ...nuptrL];
    for (var e in YR) {
      assert(!e.isNaN,
          print("rates: $YR, states:$y, weather:$wd, ET:$ET0reference"));
    }

    YR.add(irrigation); //just for reporting amount of water needed
    YR.add(wd[0]); //rain
    YR.add(actualTranspiration); //just for reporting amount of water needed
    YR.add(evaporation);
    YR.add(drain);
    YR.add(CFR);
    YR.add(PPFD);
    //print(y);
    //print(YR);

    assert(YR.length == y.length);

    for (var e in YR) {
      assert(!e.isNaN,
          print("rates: $YR, states:$y, weather:$wd, ET:$ET0reference"));
    }

    return (YR);
  }

  List<double> ode2initValues() {
    var yi = new List<double>.generate(9 + _nsl * 5, (index) => 0.0);
    final iTheta = new List<double>.generate(
        _nsl, (index) => _itheta + index * _thg); //todo
    /*# c(4.83, 10.105, 16.05, 12.955, 6.75, 4.89, 3.73) mg/kg
      # fertilizer 45 kg/rai urea (46% N) and 250 kg chicken manure with 0.5-0.9% N?
      # (45*0.46 + 250*0.07)*1e6/1600/(lvol*BD)=73 mg/kg
      # probably half of the manure is mineral. */
    final iNcont = [
      39.830,
      10.105,
      16.050,
      8.0, //guessed
      8.0, //guessed
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0
    ]; //we have no measurements for deeper layers.
    final iNRT = 6.0;
    yi[1] = _cuttingDryMass; //SDM
    yi[6] = _cuttingDryMass; //mDMs

    yi[9 + _nsl] = iNRT;
    //yi[13] = 0;
    //yi[14] = 0;
    for (int i = 0; i < _nsl; ++i) {
      //...RLR_l, ...NRTR_l, ...dThetaDt, ...NcontR_l, ...NuptR_l
      yi[9 + 2 * _nsl + i] = iTheta[i];
      yi[9 + 3 * _nsl + i] = iNcont[i] * _scaleNfert;
      yi[9 + 4 * _nsl + i] = _cuttingDryMass * 30.0 / _nsl;
    }

    yi.add(0.0); //for irrigation
    yi.add(0.0); //for rain
    yi.add(0.0); //for trans
    yi.add(0.0); //for evap
    yi.add(0.0); //for drainage
    yi.add(0.0); //for cum photosynthesis
    yi.add(0.0); //for cum light

    //print("yi=$yi");

    return (yi);
  }

  Future<bool> loadWeatherData({bool readFromBundle = true}) async {
    if (_weatherdata.isEmpty) {
      final path = "assets/weatherdata/weatherData.average.allloc.csv";
      final csvstring = (readFromBundle)
          ? await rootBundle.loadString(path)
          : File(path).readAsStringSync();
      final r = _loadWeatherData(csvstring);
      _hasRun = false; //signal to rerun.
      return r; //true, there is new data
    }
    return !_hasRun; //no new weather data, but hasRun tell if parameters changed
  }

  Future<bool> _updateParameters() async {
    //todo get rid of code repetitions.
    _SRL = _ps.getSimulationParameter(ParameterNames.SRL);
    _istart = _ps.getSimulationParameter(ParameterNames.istart);
    _iend = _istart + _ps.getSimulationParameter(ParameterNames.iend);
    //global end time and local end time (in case this is not registered in fields);
    //_igstart = min(_istart, Fields.getStartTime());
    //_igend = max(_iend, Fields.getEndTime());
    _fcThreshHold = _ps.getSimulationParameter(ParameterNames.fcThreshHold);
    _fcThreshHold *= (_ths - _thr) / 100;
    _fcThreshHold += _thr;
    final dhd = _ps
        .getSimulationParameter(ParameterNames.irrigationDripHoleDistance); //cm
    final dld = _ps
        .getSimulationParameter(ParameterNames.irrigationDripLineDistance); //cm
    final dhr =
        _ps.getSimulationParameter(ParameterNames.irrigationDripHoleRate); //l/h
    _autoIrrigate = dhr * 24.0 / (dhd * dld / 10000.0);
    _autoIrrigationDuration =
        _ps.getSimulationParameter(ParameterNames.autoIrrigateDuration) /
            24; //h to day
    _autoIrrigateTime =
        -1; //todo set to time from which point onwards auto irrigation should be enabled. -1 from beginnin.

    //note that this is compared against relative time.
    _stopIrrigation = _iend -
        _istart -
        _ps.getSimulationParameter(ParameterNames.doNotIrrigateTheLastXdays);

    if (_stopIrrigation < 1.0) _stopIrrigation = 1.0;

    _scaleRain = _ps.getSimulationParameter(ParameterNames.scaleRain) / 100;
    _scaleNfert = _ps.getSimulationParameter(ParameterNames.scaleNfert) / 100;

    final r = await loadWeatherData(); //true when new data is loaded

    //todo set weather file name
    //todo determine this.
    _irrigateFromFile = false;

    return (r);
  }

//todo generalize the convertion and reduce this.
  List<List<double>> getResultsTable() {
    return _results; // not this is without unit conversions
  }

  List<double> getResults(int n) {
    final row = (n < _results.length)
        ? _results[n]
        : List<double>.filled(_printTime.length, 0.0);
    //print("retrieving row $n with min=${row.reduce(min)} max=${row.reduce(max)}");
    switch (n) {
      case 0: //yield
        if (_convfact != 1) {
          var cr = row.map((e) => e * _convfact);
          return cr.toList();
        } else {
          return row;
        }
      case 1: //theta
        var cr = row.map((el) => 100.0 * relTheta(el));
        return cr.toList();
      case 2: //irrigation
        if (_convfact3 != 1) {
          var cr = row.map((e) => e * _convfact3);
          return cr.toList();
        } else {
          return row;
        }
      case 3: //lai
        return row;
      default:
        return row;
    }
  }

  double getDoy2(DateTime sd) {
    //todo no function overloading in dart ?
    final rsd = new DateTime(sd.year, 1, 1, 0, 0);
    double doy = sd.difference(rsd).inDays.toDouble();
    doy += sd.hour / 24.0 +
        sd.minute / (24.0 * 60.0) +
        sd.second / (24.0 * 60.0 * 60.0);
    return (doy);
  }

  // weather data loading
  List<List<dynamic>> _weatherdata = [];
  final _iRain = 1; //8;
  final _iTemp = 3; //11;
  final _iRadiation = 4; //12;
  final _iDT = 2; //13;
  final int _iRH = 5; //10;
  final int _iWind = 6; //9;
  final int _iDOY = 0; //3;
  final int _iLat = 7; //5;
  final int _iLong = 8; //6;
  final int _iElev = 9; //7;
  final int _iHeight = 10; //4;
  int _iwdRowNum = 1;

  bool _loadWeatherData(String csvstring) {
    //todo this does not work in android as assets are in a bundle archive,
    // we need to use the rootBundle, and with it async reading
    //final ;
    //print("Loading weather from $path.");
    //final ; //async
    //final csvstring = File(path).readAsStringSync();
    _weatherdata = CsvToListConverter().convert(csvstring,
        eol: '\n', fieldDelimiter: ',', shouldParseNumbers: true);

    assert(_weatherdata[0][_iRain] == "rain");
    assert(_weatherdata[0][_iTemp] == "temp");
    assert(_weatherdata[0][_iRadiation] == "radiation");
    assert(_weatherdata[0][_iDT] == "dt");
    assert(_weatherdata[0][_iLat] == "lat");
    assert(_weatherdata[0][_iLong] == "long");
    assert(_weatherdata[0][_iElev] == "elev");
    assert(_weatherdata[0][_iHeight] == "height");
    assert(_weatherdata.length > 10);

    //refdoy for first entry in weather data
    double doy =
        _weatherdata[1][_iDOY].toDouble(); //getDoy(_weatherdata[1][0]);
    _iwdRowNum = 1;
    while (_istart >= doy && _iwdRowNum < _weatherdata.length) {
      ++_iwdRowNum;
      doy = _weatherdata[_iwdRowNum][_iDOY].toDouble();
    }
    assert((_istart - doy).abs() < 0.1);

    //todo no provisions when weather data starts later than the actual simulation
    //print("starting row number is $_iwdRowNum with doy $doy and starttime $_istart");
    return true;
  }

  List<double> getWeatherData(double t) {
    //refdoy for first entry in weather data
    double doy = _weatherdata[_iwdRowNum][_iDOY].toDouble();
    while (t > 365.0) t -= 365.0; //todo use date time and check year;
    double doyn = doy + _weatherdata[_iwdRowNum][_iDT].toDouble();
    while (t > doyn && _iwdRowNum < _weatherdata.length) {
      ++_iwdRowNum;
      doy = _weatherdata[_iwdRowNum][_iDOY].toDouble();
      doyn = doy + _weatherdata[_iwdRowNum][_iDT].toDouble();
    }
    while (t < doy + 1e-9 && _iwdRowNum > 1) {
      --_iwdRowNum;
      doy = _weatherdata[_iwdRowNum][_iDOY].toDouble();
      //doyn = doy + _weatherdata[_iwdRowNum][_iDT].toDouble();
    }
    final n = _iwdRowNum;
    assert((t - doy).abs() < 0.1, print("t: $t doy: $doy"));
    //update weather
    final row = _weatherdata[n];
    //print(row);
    double dt = row[_iDT].toDouble();
    double rain = row[_iRain].toDouble() / dt; //mm to mm/day
    double temp = row[_iTemp].toDouble();
    double radiation = row[_iRadiation].toDouble();
    double relativeHumidity = row[_iRH].toDouble();
    double wind = row[_iWind].toDouble();
    double latitude = row[_iLat].toDouble();
    double longitude = row[_iLong].toDouble();
    double elevation = row[_iElev].toDouble();
    double height = row[_iHeight].toDouble();
    double ppfd = radiation * 2.15; //2.15 for conversion of energy to ppfd
    //double et0 = row[_iET0].toDouble();// this is not the reference ET, but already corrected we recalculate
    double et0 = 24.0 *
        hourlyET(temp, radiation, relativeHumidity, wind, doy, latitude,
            longitude, elevation, longitude, height);
    double irri = 0; //todo allow farmer to enter//row[_iIrrigation].toDouble();

    var YR = [
      rain,
      temp,
      ppfd,
      et0,
      irri,
      dt
    ]; //todo order here is hard coded in ode2
    for (var e in YR) {
      assert(!e.isNaN, print("weather: $YR"));
    }
    return (YR);
  }

  static final double pdt = 3.0;

  //model
  Future<bool> simulate() async {
    //print( 'Simulate is called with iLA=$_iLA SRL=$_SRL istart=$_istart iend=$_iend');
    final bool newdata = await _updateParameters();
    if (!newdata) return !newdata;
    //print('Simulating with iLA=$_iLA SRL=$_SRL istart=$_istart iend=$_iend');
    //print("running simulation for ${_ps.fieldName}");

    double t = _istart;
    var w = ode2initValues(); //ode2
    final dt =
        30.0 / (60 * 24); // 30 minutes, or as frequent as we have weather data

    int ps = min(_printSize, (_iend - _istart).ceil() ~/ pdt);
    //(_igend - _igstart) / (printSize.toDouble() - 1.0);
    var ptime =
        List<double>.generate(ps, (index) => _istart + index.toDouble() * pdt);
    // starting row in the weather file
    //double tinit = -1.0;
    //print("timeloop with t:$t _istart:$_istart _iend;$_iend dt:$pdt");
    for (int i = 0; i < ptime.length; ++i) {
      //forward simulation
      var wd = getWeatherData(t);
      var tw = t + wd[5];
      while (t < ptime[i] - 0.5 * dt) {
        final wddt = max(1e-10, min(min(dt, wd[5]), ptime[i] - t));
        //do step
        rk4Step(t - _istart, w, wddt, wd); //
        t += wddt;
        //todo not guaranteed to land on the next weather time
        //next row in weather data
        if (t > tw) {
          wd = getWeatherData(t);
          tw = t + wd[5];
        }
      }

      //for ode1 use index 0 and 1 for ode2, srdw en theta top, index 3 and 15
      //todo work out a better indexing which is also clear in the interface.
      _printTime[i] = t;
      _results[0][i] =
          w[3] * 10 / _APPi; //yield, convert g/plant to kg/ha (default)
      _results[1][i] = w[9 + 2 * _nsl]; //theta
      _results[2][i] = w[9 + 5 * _nsl]; //irrigation
      _results[3][i] = w[4] / _APPi; //lai
      _results[4][i] =
          100.0 + 100.0 * w[8] / max(1.0, w[0] + w[1] + w[2] + w[3]); //clab
      _results[5][i] = w[9 + 5 * _nsl + 5]; //photo
      _results[6][i] = w[9 + 3 * _nsl]; //topsoil ncont
      int ri = 9 + 4 * _nsl;
      final Nopt = 45 * w[0] + 2 * w[3] + 20 * w[1] + 20 * w[2];
      _results[7][i] = (w.sublist(ri, ri + _nsl)).sum / max(1.0, Nopt); //nupt
    }
    _hasRun = true;
    return _hasRun;
  }

  void rk4Step(double t, List<double> y, double dt, List<double> wd) {
    var yp =
        List<double>.from(y, growable: false); // needs to be an explicit copy
    //print('y0=$y');
    var r1 = ode2(t, yp, wd);
    var t1 = t + 0.5 * dt;
    var t2 = t + dt;
    intStep(yp, r1, 0.5 * dt);
    var r2 = ode2(t1, yp, wd);
    for (int i = 0; i < y.length; i++) yp[i] = y[i]; //reset
    intStep(yp, r2, 0.5 * dt);
    var r3 = ode2(t1, yp, wd);
    for (int i = 0; i < y.length; i++) yp[i] = y[i]; //reset
    intStep(yp, r3, dt);
    var r4 = ode2(t2, yp, wd);
    for (int i = 0; i < r4.length; i++)
      r4[i] = (r1[i] + 2 * (r2[i] + r3[i]) + r4[i]) / 6; //rk4
    //print('y1=$y');
    intStep(y, r4, dt); //final integration
    //print('y2=$y');
  }

  void intStep(final List<double> y, final List<double> r, final double dt) {
    assert(y.length == r.length);
    for (int i = 0; i < y.length; ++i) {
      y[i] += dt * r[i];
    }
  }
}
