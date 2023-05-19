import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

bool USE_FIRESTORE_EMULATOR = true;

void main() async 
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    // ... other providers
  ]);
  //await FirebaseAppCheck.instance.activate(webRecaptchaSiteKey: '6Ldea-8lAAAAANxLrACahMUCkA4ob0zPsebV6Djn',);
// Ideal time to initialize
  if (kDebugMode) {
    //await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    //final firestore = FirebaseFirestore.instance;
    //firestore.settings =
        //const Settings(persistenceEnabled: true, sslEnabled: false);
    //firestore.useFirestoreEmulator('localhost', 8080);
    final cloudFunctions = FirebaseFunctions.instance;
    cloudFunctions.useFunctionsEmulator('localhost', 5001);
  }
  runApp(const MyApp());
}






