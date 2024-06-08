import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:provider/provider.dart';
import 'MyFlowersPage.dart';
import 'package:appjam/Welcome.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çiçek Bakım Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: SplashScreen(), // veya başlangıç sayfanızı buraya ekleyin
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ObjectDetectionScreen()),
                );
              },
              child: Text('Çiçek Tanımlayıcı'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyFlowersPage()),
                );
              },
              child: Text('Kendi Çiçeklerim'),
            ),
          ],
        ),
      ),
    );
  }
}



class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({Key? key});

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  String _detectionResult = "";

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = image;
          file = File(image.path);
        });
        detectImage(file!);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> detectImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _detectionResult = formatRecognitionResults(recognitions).substring(6);
    });
  }

  String formatRecognitionResults(List<dynamic>? recognitions) {
    if (recognitions == null) {
      return "No recognitions found";
    }

    return recognitions.map((rec) {
      String label = rec["label"];
      double confidence = rec["confidence"];
      return "%${(confidence * 100).toStringAsFixed(0)} $label";
    }).join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          'Çiçek Tanımlayıcı',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26, width: 15),
                ),
                child: Image.file(
                  File(_image!.path),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Text(
                'Çiçeği Tanımlamak İçin Galeriden Seçim Yapın',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,// 24, metnin boyutunu belirleyen örnek bir değer
              ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Galeriden Seç'),
            ),
            const SizedBox(height: 20),
            Text(
              _detectionResult,
              style: TextStyle(fontSize: 30), // 24, metnin boyutunu belirleyen örnek bir değer
            ),
            if (_detectionResult.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyFlowersPage()),
                  );
                },
                child: const Text('Kendi Çiçeklerim'),
              ),
          ],
        ),
      ),
    );
  }
}
