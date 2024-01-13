import 'dart:io';
import 'dart:math';

import 'package:biomatricauth/logIn.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  File? _image;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final File newImage = await _image!.copy('$path/fingerprint.png');
      saveImage(newImage.path);
    }
  }

  Future<void> saveImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fingerprintImagePath', path);
  }

  Future<void> saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', emailController.text);
    await prefs.setString('password', passwordController.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email or UserID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              _image == null
                  ? Text('No image selected.')
                  : Container(
                      height: 150, width: 300, child: Image.file(_image!)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: pickImage,
                child: Text('Click Fingerprint Image'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: saveCredentials,
                child: Text('Signup'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: (){
                  Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
