import 'package:MobileSystemsPass/src/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:MobileSystemsPass/src/functions/note_handler.dart';

void main() {
  NoteHandler.init();
  Firebase.initializeApp();
  runApp(App());
}


