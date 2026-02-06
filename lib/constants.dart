import 'package:flutter/material.dart';

    final  kTextFilledDecoration =  InputDecoration(
        labelText: "Email" ,
        labelStyle: TextStyle(
          color: Colors.grey,
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey ,
            )
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF9E0815),
            )
        ),
        prefixIcon: const Icon(Icons.email_outlined),
        hintText: "student@enstab.ucar.tn",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12) ,
        )
    ) ;