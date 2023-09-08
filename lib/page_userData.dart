//import 'package:direction/fieldEntryForm.dart';
//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //generate code for language switch
import 'package:direction/classFields.dart';
import 'package:direction/classParameterSet.dart';
//import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:direction/colorPickerWidget.dart';

//jp sqflite imports to store data locally
//import 'dart:async';
//import 'package:path/path.dart';
//import 'package:sqflite/sqflite.dart';

//package for pop-up form
//import 'package:rflutter_alert/rflutter_alert.dart';

//import 'package:direction/classParameterSet.dart';
//final _dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
String formatDates(DateTime d) {
  return ("${d.day}/${d.month}/${d.year}");
}

class UserDataPage extends StatefulWidget {
  UserDataPage({Key? key, required this.title}) : super(key: key) {
    //print("constructor UserDataPage called");
    //Fields.fromDisk();
  }

  final String title;

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  //int _counter = 0;

  //var fieldList = List<ParameterSet>.empty();
  // var fieldList = [
  //   ParameterSet(fieldName: 'f1'),
  //   ParameterSet(fieldName: 'f2'),
  // ];
  //
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();

  int updateTrigger = -1;
  double slv1 = 0.0;

  bool _databaseInit = false;
  @override
  void initState() {
    super.initState();
    _databaseInit = false; //reset
    _fromDisk();
  }

  Future _fromDisk() async {
    var fut = Fields.fromDisk();
    // call setState here to set the actual list of items and rebuild the widget.
    fut.then((value) => setState(() {
          _databaseInit = value;
        }));
  }

  void addItemToList() {
    setState(() {
      Fields.insert(nameController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    //todo move this to the where new database is created.
    if (Fields.length() < 1 && _databaseInit)
      Fields.insert(AppLocalizations.of(context)!.hintFieldName);

    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: <Widget>[
//
        if (Fields.length() > 0)
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(8),
                itemCount: Fields.length(),
                itemBuilder: (BuildContext context, int index) {
                  final item = Fields.at(index);
                  return Dismissible(
                    // Each Dismissible must contain a Key. Keys allow Flutter to
                    // uniquely identify widgets.
                    key: Key(item.id.toString()),
                    // Provide a function that tells the app
                    // what to do after an item has been swiped away.
                    onDismissed: (direction) {
                      // Remove the item from the data source.
                      setState(() {
                        Fields.removeAt(index);
                      });

                      // Then show a snackbar.
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(AppLocalizations.of(context)!
                              .fieldNameDismissed(item.fieldName))));
                    },
                    // Show a red background as the item is swiped away.
                    background: Container(color: Colors.red),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldEditingForm(
                                  index: index,
                                  onUpdate: () {
                                    setState(() {
                                      this.updateTrigger++;
                                      Fields.toDisk();
                                    });
                                  },
                                ),
                              ),
                            );
                          });
                        },
                        leading: Icon(
                          Icons.stop,
                          color: item.getColor(),
                        ),
                        //tileColor: item.getColor(),
                        title: Text('${item.fieldName}'),
                        trailing: Icon(Icons.more_vert),
                      ),
                    ),
                    //onTap: () => print("ListTile is tapped")
                  );
                }),
          ),
        //
        //
        //
        //
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: () {
          if (Fields.length() < 5 && _databaseInit) {
            showDialog(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Stack(
                    children: <Widget>[
                      //
                      //
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .hintFieldName,
                                ),
                                controller: nameController,
                                //..text = 'myCassavaField1',
                                //onChanged: (text) => {Fields.insert(text)},
                                validator: (value) {
                                  //todo look for unique name. Now the Fields class add's '+' to the name if it is not unique
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .pleaseEnterUniqueFieldName;
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (text) {
                                  // Validate returns true if the form is valid, or false otherwise.
                                  if (_formKey.currentState!.validate()) {
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .addingField)));
                                    addItemToList();
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .cancel),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Validate returns true if the form is valid, or false otherwise.
                                          if (_formKey.currentState!
                                              .validate()) {
                                            // If the form is valid, display a snackbar. In the real world,
                                            // you'd often call a server or save the information in a database.
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .addingField)));
                                            addItemToList();
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .submit),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      //
                      //
                    ],
                  ),
                );
              },
            );
          } else {
            if (_databaseInit) {
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(children: <Widget>[
                      Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      Text(AppLocalizations.of(context)!.error)
                    ]),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(AppLocalizations.of(context)!.tooManyFields),
                          Text(AppLocalizations.of(context)!.pleaseRemoveField),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.returnMsg),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              // database is not loaded
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(children: <Widget>[
                      Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      Text(AppLocalizations.of(context)!.error)
                    ]),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(
                              AppLocalizations.of(context)!.waitForDataLoading),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.returnMsg),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}

class FieldEditingForm extends StatefulWidget {
  //must be stateful for sliders otherwise not redrawn.
  FieldEditingForm({Key? key, required this.index, required this.onUpdate})
      : super(key: key);

  final int index;
  final Function onUpdate; //callback function which will triger an update

  @override
  _FieldEditingFormState createState() =>
      _FieldEditingFormState(index: index, onUpdate: onUpdate);
}

class _FieldEditingFormState extends State<FieldEditingForm> {
  // Declare a field that holds the Todo.
  final int index;
  final Function onUpdate; //callback function which will triger an update

  // In the constructor, require a Todo.
  _FieldEditingFormState({required this.index, required this.onUpdate});

  // Date selection
  //todo reference year is not safed, meaning we will jump back to the current
  //better to safe the real dates and do these calculations in the model
  late DateTime plantingDate = DateTime(DateTime.now().year, 1).add(Duration(
      days: Fields.at(index)
          .getSimulationParameter(ParameterNames.istart)
          .toInt()));
  late DateTime harvestDate = plantingDate.add(Duration(
      days: Fields.at(index)
          .getSimulationParameter(ParameterNames.iend)
          .toInt()));

  double getDoy(DateTime sd, {int year = -1}) {
    if (year < 0) year = sd.year;
    final rsd = new DateTime(year, 1, 1, 0, 0);
    double doy = sd.difference(rsd).inDays.toDouble();
    doy += sd.hour / 24.0 +
        sd.minute / (24.0 * 60.0) +
        sd.second / (24.0 * 60.0 * 60.0);
    return (doy);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: plantingDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2026, 1));
    if (picked != null && picked != plantingDate) {
      setState(() {
        plantingDate = picked;
        double dur = getDoy(plantingDate);
        /*if (dur > ParameterNames.istart.max())
          dur = ParameterNames.istart.max();
        if (dur < ParameterNames.istart.min())
          dur = ParameterNames.istart.min();*/
        Fields.at(index).setSimulationParameter(ParameterNames.istart, dur);
        harvestDate = plantingDate.add(Duration(
            days: Fields.at(index)
                .getSimulationParameter(ParameterNames.iend)
                .toInt()));
      });
    }
  }

  Future<void> _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: plantingDate.add(Duration(
          days: Fields.at(index)
              .getSimulationParameter(ParameterNames.iend)
              .toInt())),
      firstDate: plantingDate,
      lastDate:
          plantingDate.add(Duration(days: ParameterNames.iend.max().toInt())),
    );
    if (picked != null && picked != harvestDate) {
      setState(() {
        double dur = picked
            .difference(plantingDate)
            .inDays
            .toDouble(); //getDoy(harvestDate, year: plantingDate.year);
        if (dur > ParameterNames.iend.max()) dur = ParameterNames.iend.max();
        if (dur < ParameterNames.iend.min()) dur = ParameterNames.iend.min();
        Fields.at(index).setSimulationParameter(ParameterNames.iend, dur);
        //harvestDate = picked;
        plantingDate.add(
            Duration(days: dur.toInt())); //is picked, but this here to check.
      });
    }
  }

  bool _expertMode = false;
  void _toggleExpertMode() {
    setState(() {
      (_expertMode) ? _expertMode = false : _expertMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!
            .editFieldName(Fields.at(index).fieldName)),
      ),
      body: /*SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[*/
          Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.fieldName,
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (String newString) {
                  Fields.at(index).fieldName = newString;
                  this.onUpdate();
                },
                //onEditingComplete:(String newString) => print('complete'),
                //onSubmitted: (String newString) => print('update'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: Fields.at(index).fieldName,
                ),
              ),
            ),

            //
            //
            //
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.fieldColor,
                  ),
                ],
              ),
            ),
            // Icon(
            //   Icons.stop,
            //   color: Fields.at(index).getColor(),
            // ),
            // SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: MyColorPicker(
                  onSelectColor: (value) {
                    Fields.at(index).setColor(value);
                    this.onUpdate();
                  },
                  availableColors: Fields.at(index).getColors(),
                  initialColor: Fields.at(index).getColor()),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text("${formatDates(plantingDate)}"),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child:
                        Text(AppLocalizations.of(context)!.selectPlantingDate),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text("${formatDates(harvestDate)}"),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate2(context),
                    child:
                        Text(AppLocalizations.of(context)!.selectHarvestDate),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.all(8),
                  itemCount:
                      ParameterNamesExtension.numberToShow(expert: _expertMode),
                  itemBuilder: (BuildContext context, int j) {
                    final item = ParameterNamesExtension.reorder(j);
                    final double cv = item.unitConv(context);
                    final double minv = item.min() * cv;
                    final double maxv = item.max() * cv;
                    return new Column(
                      children: <Widget>[
                        new ListTile(
                          title: new Text(
                              "${item.prettyName(context)} (${item.unit(context)})"),
                          subtitle: new Text(
                              "${cv * Fields.at(index).getSimulationParameter(item)}"),
                        ),
                        new Divider(
                          height: 2.0,
                        ),
                        RepaintBoundary(
                          child: Slider(
                            value: (cv *
                                Fields.at(index).getSimulationParameter(item)),
                            min: minv,
                            max: maxv,
                            divisions: 100,
                            label: (cv *
                                    Fields.at(index)
                                        .getSimulationParameter(item))
                                .toStringAsFixed(4),
                            onChanged: (double value) {
                              setState(() {
                                Fields.at(index)
                                    .setSimulationParameter(item, value / cv);
                              });
                              //print(value);
                              //sv1 = value;

                              //Fields.at(index).setRGR(value);
                            },
                          ),
                        ),
                        new Divider(
                          height: 2.0,
                        ),
                      ],
                    );
                  }),
            ),
//

            const SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              onPressed: () => _toggleExpertMode(),
              child: (_expertMode)
                  ? Text(AppLocalizations.of(context)!.showLess)
                  : Text(AppLocalizations.of(context)!.showMore),
            ),
          ],
        ),
      ),
      /*],
          ),
        ),
      ),*/
    );
  }
}
