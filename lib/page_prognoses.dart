//import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //generate code for language switch
//jp library to draw charts
//install with
//flutter pub add draw_graph
// this automatically adds the dep to the pubspec.yaml
import 'package:direction/draw_graph/draw_graph.dart'; //mit license
//import 'package:draw_graph/models/feature.dart';
import 'package:direction/classFields.dart';
import 'package:direction/classParameterSet.dart';

class PrognosesPage extends StatefulWidget {
  PrognosesPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _PrognosesPageState createState() {
    return _PrognosesPageState();
  }
}

class _PrognosesPageState extends State<PrognosesPage> {
  bool _simulationRan = false;
  @override
  void initState() {
    super.initState();
    _simulationRan = false; //reset
    _simulate(); //todo better start when page loaded, as this quite heavy and slows down app a lot
  }

  Future _simulate() async {
    var fut = Fields.runSimulations();
    // call setState here to set the actual list of items and rebuild the widget.
    fut.then((value) => setState(() {
          _simulationRan = value;
        }));
  }

  bool _expertMode = false;
  void _toggleExpertMode() {
    setState(() {
      (_expertMode) ? _expertMode = false : _expertMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    SimulationModel.setConversionFactors(context);
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false, //jp added because of graph
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (Fields.length() < 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64.0),
                    child: Text(
                      AppLocalizations.of(context)!.pleaseAddField,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.red,
                      ),
                    ),
                  ),
                if (Fields.length() > 0 && !_simulationRan)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64.0),
                    child: Text(
                      AppLocalizations.of(context)!.waitForSimulation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.red,
                      ),
                    ),
                  ),
                if (Fields.length() > 0 && _simulationRan)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64.0),
                    child: Text(
                      AppLocalizations.of(context)!.tab1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                if (Fields.length() > 0 && _simulationRan)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64.0),
                    child: Text(
                      Fields.getPredictions(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 1,
                          color: Colors.black87),
                    ),
                  ),
                if (Fields.length() > 0 && _simulationRan)
                  LineGraph(
                    features: Fields.getFeatures(0),
                    size: Size(420, 400),
                    labelX: Fields.getFeaturesX(context),
                    labelY: Fields.getFeaturesY(0),
                    xlab: AppLocalizations.of(context)!.xlabTime,
                    ylab: AppLocalizations.of(context)!.ylabYield,
                    showDescription: true, //shows legend
                    graphColor: Colors.black87,
                  ),
                SizedBox(
                  height: 150,
                ),
                if (Fields.length() > 0 && _simulationRan)
                  LineGraph(
                    features: Fields.getFeatures(2),
                    size: Size(420, 400),
                    labelX: Fields.getFeaturesX(context),
                    labelY: Fields.getFeaturesY(2),
                    xlab: AppLocalizations.of(context)!.xlabTime,
                    ylab: AppLocalizations.of(context)!.ylabIrrigation,
                    showDescription: true, //shows legend
                    graphColor: Colors.black87,
                  ),
                SizedBox(
                  height: 150,
                ),
                ElevatedButton(
                  onPressed: () => _toggleExpertMode(),
                  child: (_expertMode)
                      ? Text(AppLocalizations.of(context)!.showLess)
                      : Text(AppLocalizations.of(context)!.showMore),
                ),
                SizedBox(
                  height: 150,
                ),
                if (Fields.length() > 0 && _simulationRan && _expertMode)
                  LineGraph(
                    features: Fields.getFeatures(3),
                    size: Size(420, 400),
                    labelX: Fields.getFeaturesX(context),
                    labelY: Fields.getFeaturesY(3),
                    xlab: AppLocalizations.of(context)!.xlabTime,
                    ylab: AppLocalizations.of(context)!.leafAreaIndex, //todo
                    showDescription: true, //shows legend
                    graphColor: Colors.black87,
                  ),
                SizedBox(
                  height: 150,
                ),
                if (Fields.length() > 0 && _simulationRan && _expertMode)
                  LineGraph(
                    features: Fields.getFeatures(1),
                    size: Size(420, 400),
                    labelX: Fields.getFeaturesX(context),
                    labelY: Fields.getFeaturesY(1),
                    xlab: AppLocalizations.of(context)!.xlabTime,
                    ylab: AppLocalizations.of(context)!.parameterNameTheta,
                    showDescription: true, //shows legend
                    graphColor: Colors.black87,
                  ),
                SizedBox(
                  height: 50,
                ),
                if (Fields.length() > 0 && _simulationRan && _expertMode)
                  LineGraph(
                    features: Fields.getFeatures(4),
                    size: Size(420, 400),
                    labelX: Fields.getFeaturesX(context),
                    labelY: Fields.getFeaturesY(4),
                    xlab: AppLocalizations.of(context)!.xlabTime,
                    ylab:
                        AppLocalizations.of(context)!.parameterNameLabileCarbon,
                    showDescription: true, //shows legend
                    graphColor: Colors.black87,
                  ),
                SizedBox(
                  height: 50,
                ),
                if (Fields.length() > 0 && _simulationRan && _expertMode)
                  LineGraph(
                    features: Fields.getFeatures(5),
                    size: Size(420, 400),
                    labelX: Fields.getFeaturesX(context),
                    labelY: Fields.getFeaturesY(5),
                    xlab: AppLocalizations.of(context)!.xlabTime,
                    ylab: AppLocalizations.of(context)!
                        .parameterNamePhotoSynthesis,
                    showDescription: true, //shows legend
                    graphColor: Colors.black87,
                  ),
                SizedBox(
                  height: 50,
                ),
                if (Fields.length() > 0 && _simulationRan && _expertMode)
                  LineGraph(
                    features: Fields.getFeatures(6),
                    size: Size(420, 400),
                    labelX: Fields.getFeaturesX(context),
                    labelY: Fields.getFeaturesY(6),
                    xlab: AppLocalizations.of(context)!.xlabTime,
                    ylab: AppLocalizations.of(context)!
                        .parameterNameTopSoilNcontent,
                    showDescription: true, //shows legend
                    graphColor: Colors.black87,
                  ),
                SizedBox(
                  height: 50,
                ),
                if (Fields.length() > 0 && _simulationRan && _expertMode)
                  LineGraph(
                    features: Fields.getFeatures(7),
                    size: Size(420, 400),
                    labelX: Fields.getFeaturesX(context),
                    labelY: Fields.getFeaturesY(7),
                    xlab: AppLocalizations.of(context)!.xlabTime,
                    ylab: AppLocalizations.of(context)!.parameterNameNi,
                    showDescription: true, //shows legend
                    graphColor: Colors.black87,
                  ),
                SizedBox(
                  height: 50,
                ),
                if (_expertMode)
                  ElevatedButton(
                    onPressed: () => _toggleExpertMode(),
                    child: (_expertMode)
                        ? Text(AppLocalizations.of(context)!.showLess)
                        : Text(AppLocalizations.of(context)!.showMore),
                  ),
              ]),
        ),
      ),
    );
  }
}
