import 'package:flutter/material.dart';
import 'package:enstabhouse/screens/login_screen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
       appBarTheme:const AppBarTheme(
         backgroundColor: Color(0xFF9E0815) ,
           surfaceTintColor: Colors.transparent,
           centerTitle: true,
           titleTextStyle: TextStyle(
             color: Colors.white,
             fontSize: 20,
             fontWeight: FontWeight.bold,
       ),
       ),
      ),
        home: LoginScreen(),
    );

  }
}