import 'package:flutter/material.dart';

const  kTextProperties =  TextStyle(
color: Color(0xFF9E1B1B),
fontSize: 28,
fontWeight: FontWeight.bold,
) ;

final kWelcomePageButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF990011),
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  elevation: 0 ,
);


const KTextFieldDecoration =  InputDecoration(
  filled: true ,
  fillColor: Colors.white ,
  hintStyle: TextStyle(color: Colors.grey,
  ),
  border: OutlineInputBorder(
    borderRadius:BorderRadius.all(Radius.circular(10.0)
    ),
    borderSide: BorderSide.none  ,
  ),
);

final kEmailDecoration = KTextFieldDecoration.copyWith(hintText: 'Enter your email');

final kPasswordDecoration = KTextFieldDecoration.copyWith(hintText: 'Enter your password');

const kTextLoginProperties =  TextStyle(
  color: Color(0xFF9E1B1B),
  fontSize: 15,
  fontWeight: FontWeight.bold,
) ;
const kTextForgotProperties =  TextStyle(
  color: Color(0xFF9E1B1B),
  fontSize: 12.0,
  fontWeight: FontWeight.bold,
) ;

final kButtonLoginPageProperties = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF990011),
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 150.0, vertical: 20),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  elevation: 0 ,
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter your email ',
  fillColor: Colors.white,
  filled: true,
  contentPadding:
  EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide:
    BorderSide(color: Color(0xFF9E1B1B), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide:
    BorderSide(color: Color(0xFF9E1B1B), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);