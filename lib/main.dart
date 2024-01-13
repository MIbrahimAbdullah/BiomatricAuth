import 'package:biomatricauth/logIn.dart';
import 'package:biomatricauth/signUp.dart';
import 'package:biomatricauth/test.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: LoginPage(),
    ),
  );
}

