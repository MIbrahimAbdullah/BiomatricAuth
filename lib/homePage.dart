import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _storedImage;
  File? _newImage;

  @override
  void initState() {
    super.initState();
    loadStoredImage();
  }

  Future<void> loadStoredImage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedImagePath = prefs.getString('fingerprintImagePath');
    if (storedImagePath != null) {
      setState(() {
        _storedImage = File(storedImagePath);
      });
    }
  }

  Future<void> takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 10),
              Text("Loading..."),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 10));

    // Closing the loading spinner
    Navigator.of(context).pop();

    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  void compareImages() async {
    if (_newImage == null) {
      showAlertDialog('Error', 'No image to compare');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text("Comparing Images..."),
            ],
          ),
        );
      },
    );

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://usama03.pythonanywhere.com/matching/'));
      request.files
          .add(await http.MultipartFile.fromPath('image', _newImage!.path));

      var response = await request.send();

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var decodedResponse = json.decode(responseString);

        showAlertDialog('Match Found',
            'First Name: ${decodedResponse['FirstName']}\nID: ${decodedResponse['ID']}\nLast Name: ${decodedResponse['LastName']}');
      } else {
        print("Response${response.statusCode}");
        print("Response Body ${response.stream}");
        // showAlertDialog('Ibrahim Work\nNo Match Found',
        //     'First Name: Unknown \nID: --\nLast Name: UnKnown');
      }
    } catch (e) {
      Navigator.of(context).pop();
      showAlertDialog('Error', 'An error occurred while comparing images');
    }
  }

  void showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture New Fingerprint')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("Ibrahim's Work\nJust for Testing"),
              const SizedBox(
                height: 20,
              ),
              (_newImage != null)
                  ? Container(height: 250, child: Image.file(_newImage!))
                  : Container(),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: takePicture,
                child: const Text('Capture New Fingerprint'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  compareImages();
                },
                child: const Text('Compare Images'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
