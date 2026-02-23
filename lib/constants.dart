import 'package:flutter/material.dart';

// 🔹 Couleur primaire ENSTAB — utilisée dans tout le projet
const Color kPrimaryColor = Color(0xFF9E0815);
const Color kPrimaryDarkColor = Color(0xFF7d1616);

// 🔹 Décoration réutilisable pour les TextFields
final kTextFilledDecoration = InputDecoration(
  labelText: "Email",
  labelStyle: const TextStyle(
    color: Colors.grey,
  ),
  enabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey,
    ),
  ),
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(
      color: kPrimaryColor,
    ),
  ),
  prefixIcon: const Icon(Icons.email_outlined),
  hintText: "student@enstab.ucar.tn",
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),
);