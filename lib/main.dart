import 'package:flutter/material.dart';
//languages see https://docs.flutter.dev/development/accessibility-and-localization/internationalization
//TODO ios language support needs additional steps in xcode, see website above
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //generate code for language switch

//database management
import 'dart:io' show Platform;
import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:path/path.dart';
//import 'package:sqflite/sqflite.dart';

//project files
import 'package:direction/page_welcome.dart';
import 'package:direction/page_userData.dart';
import 'package:direction/page_prognoses.dart';
//import 'package:direction/page_prognoses_simplified.dart';
//import 'package:direction/classFields.dart';

//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';

Future main() async {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
    //init firebase
    /*await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );*/ //dissabled to support linux
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //onGenerateTitle: (BuildContext context) =>
      //    {AppLocalizations.of(context).tab1},
      title: 'DIRECTION-cassava',
      //locale: Locale('th'),
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('th', ''), // Thai, no country code
        Locale('vi', ''), // Thai, no country code
        Locale('zh', ''), // Thai, no country code
      ],
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      //home: MyHomePage(title: 'Cassava irrigation'),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              flexibleSpace: new Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.agriculture)),
                    Tab(icon: Icon(Icons.table_chart_outlined)),
                    Tab(icon: Icon(Icons.analytics)),
                    //Tab(icon: Icon(Icons.analytics_sharp)),
                  ],
                ),
              ])),
          body: TabBarView(
            children: [
              MyHomePage(title: ""),
              UserDataPage(title: ""),
              //PrognosesPageSimplified(title: ""),
              PrognosesPage(title: ""),
            ],
          ),
        ),
      ),
    );
  }
}
