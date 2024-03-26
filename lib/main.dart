import 'dart:async';
import 'package:flutter/material.dart';
import 'functions.dart';
import 'screens/main_screen.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      MaterialApp(
        theme: ThemeData(
          fontFamily: 'Bahnschrift',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Color(0xFF0E0E0E),
        ),
          debugShowCheckedModeBanner: false,
          home: ChangeNotifierProvider(
            create: (context) => functions(),
            child: MyApp(),
          ),
      )
  );
}





