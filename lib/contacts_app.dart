import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';

class ContactsApp extends StatelessWidget {
  const ContactsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const Home(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
            primaryTextTheme:
                const TextTheme(headline6: TextStyle(color: Colors.white))));
  }
}
