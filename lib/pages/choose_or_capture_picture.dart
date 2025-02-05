import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import '../widgets/face_painter.dart';
import '../database/database_helper.dart';
import '../models/face_model.dart';
import '../utils/image_utils.dart';
import 'face_list_page.dart';

class ChooseOrCapturePicture extends StatefulWidget {
  const ChooseOrCapturePicture({super.key});

  @override
  State<ChooseOrCapturePicture> createState() => ChooseOrCapturePictureState();
}

class ChooseOrCapturePictureState extends State<ChooseOrCapturePicture> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<Face> _faces = [];
  ui.Image? _imageUi;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus storageStatus = await Permission.storage.request();

    if (!cameraStatus.isGranted || !storageStatus.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permissions not granted!")),
      );
    }
  }

  Future<void> chooseOrCaptureImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final File imageFile = File(image.path);
      await detectFaces(imageFile);
    }
  }

  Future<void> detectFaces(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true,
      ),
    );

    final List<Face> faces = await faceDetector.processImage(inputImage);
    await faceDetector.close();

    if (!mounted) return;

    if (faces.isNotEmpty) {
      final uiImage = await ImageUtils.loadImage(imageFile);
      if (!mounted) {
        return; // Ensure the widget is still mounted after async operation
      }
      setState(() {
        _image = imageFile;
        _faces = [faces.first]; // Keep only ONE face
        _imageUi = uiImage;
      });
    } else {
      setState(() {
        _image = null;
        _faces = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No face detected! Try again.")),
      );
    }
  }

  Future<void> saveFace() async {
    if (_image != null && _nameController.text.isNotEmpty) {
      final face = FaceModel(
        name: _nameController.text,
        imagePath: _image!.path,
      );

      await DatabaseHelper.instance.insertFace(face);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${_nameController.text} saved!")),
      );

      clearImage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name first!")),
      );
    }
  }

  Future<void> deleteFace(int id) async {
    try {
      await DatabaseHelper.instance.deleteFace(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Face with ID $id deleted!")),
      );

      clearImage();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete face: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Recognition App')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_image != null)
            Center(
              child: CustomPaint(
                size: const Size(150, 150),
                painter:
                    _imageUi != null ? FacePainter(_imageUi!, _faces) : null,
              ),
            )
          else
            Center(child: const Icon(Icons.image, size: 150)),
          const SizedBox(height: 20),
          if (_faces.isEmpty) ...[
            ElevatedButton(
              onPressed: () => chooseOrCaptureImage(ImageSource.camera),
              child: const Text("Capture Image",
                  style: TextStyle(color: Color(0xFF06402b))),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => chooseOrCaptureImage(ImageSource.gallery),
              child: const Text("Choose Image",
                  style: TextStyle(color: Color(0xFF06402b))),
            ),
          ] else if (_faces.isNotEmpty) ...[
            Container(
              width: MediaQuery.of(context).size.width - 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  labelText: 'Enter Name',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => saveFace(),
              child: const Text("Save Face",
                  style: TextStyle(color: Color(0xFF06402b))),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => deleteFace(int.parse(_nameController.text)),
              child: const Text("Delete Face",
                  style: TextStyle(color: Color(0xFF06402b))),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: clearImage,
              child: const Text("Clear Image",
                  style: TextStyle(color: Color(0xFF06402b))),
            ),
          ]
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FaceListPage()),
          );
        },
        backgroundColor: Colors.white,
        child:  Icon(
          Icons.photo_album_outlined,
          color: Color(0xFF06402b),
        ), // Set background color
      ),
    );
  }

  void clearImage() {
    setState(() {
      _image = null;
      _faces = [];
      _imageUi = null;
      _nameController.clear();
    });
  }
}
