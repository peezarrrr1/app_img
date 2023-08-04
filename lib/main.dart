import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ImageUploadScreen(),
      theme: ThemeData(primarySwatch: Colors.amber),
    );
  }
}

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _uploadedImageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      try {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child("images/${DateTime.now()}.png");
        await ref.putFile(_imageFile!);
        String downloadUrl = await ref.getDownloadURL();
        setState(() {
          _uploadedImageUrl = downloadUrl;
        });
      } catch (e) {
        FlutterError.onError = (execption) {
          FlutterError.presentError(execption);
          if (kReleaseMode) exit(1);
        };
      }
    }
  }

  Future<void> _deleteImage() async {
    if (_uploadedImageUrl != null) {
      try {
        Reference ref = FirebaseStorage.instance.refFromURL(_uploadedImageUrl!);
        await ref.delete();
        setState(() {
          _uploadedImageUrl = null;
        });
      } catch (execption) {
        FlutterError.onError = (execption) {
          FlutterError.presentError(execption);
          if (kReleaseMode) exit(1);
        };
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Upload"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                height: 200,
                width: 200,
              ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image"),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text("Upload Image"),
            ),
            if (_uploadedImageUrl != null)
              Image.network(
                _uploadedImageUrl!,
                height: 200,
                width: 200,
              ),
            ElevatedButton(
              onPressed: _deleteImage,
              child: const Text("Delete Image"),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
