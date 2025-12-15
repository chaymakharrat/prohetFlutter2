import 'package:flutter/material.dart';
import 'app.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await testReservation();
  //await loadReservations();
  print("Firebase initialisé");
  runApp(const RideShareApp());
}
