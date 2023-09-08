//import 'package:flutter_test/flutter_test.dart';
import 'package:direction/classParameterSet.dart';
import 'dart:math';
//import 'dart:async';

void main() async {
  //testWidgets('classParameterSet ...', (tester) async {
  //create default parameter set with a name
  ParameterSet ps = new ParameterSet(fieldName: "testField");

  //optionally set some parameters
  //ps.setSimulationParameter(ParameterNames.istart, 1.0);
  //ps.setSimulationParameter(ParameterNames.iend, 270.0);
  //etc

  // run simulation
  bool simulationRan = await ps.runSimulation(readFromBundle: false);
  //print("Print simulation finished with $simulationRan");

  // request the simulation result
  var result = ps.getFeatureData(0); //int sets the type of data you want

  // print the result to screen
  print(
      "fieldname:${ps.fieldName} yield max: ${result.reduce(max) / 1000} ton/ha");

  // write table of results
  var r = ps.getSimulationResults();
  var no = r.length;
  var ni = r[0].length;
  for (int i = 0; i < ni; ++i) {
    String line = "";
    for (int j = 0; j < no; ++j) {
      line += "\t${r[j][i]}";
    }
    //print(line);
  }
  //});
}
