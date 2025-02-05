import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:ui' as ui;
import '../widgets/face_painter.dart';

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
  bool _isLoading = false;

  // Choose or capture image
  Future<void> chooseOrCaptureImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _isLoading = true);
      final File imageFile = File(image.path);
      await detectFaces(imageFile);
    }
  }

  // Detect faces using Google ML Kit
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
    await faceDetector.close(); // Close detector to free resources

    setState(() {
      _image = imageFile;
      _faces = faces;
      _isLoading = false;
    });

    await loadImage(imageFile);
  }

  // Load image for display
  Future<void> loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) {
      setState(() => _imageUi = value);
    });
  }

  // Clear image and reset faces
  void clearImage() {
    setState(() {
      _image = null;
      _faces = [];
      _imageUi = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Face Recognition App',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF06402b),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildFaceDetectionInfo(),
            buildImageDisplay(),
            _isLoading ? const CircularProgressIndicator() : buildControlButtons(),
            buildClearButton(),
          ],
        ),
      ),
    );
  }

  Widget buildFaceDetectionInfo() {
    return _faces.isNotEmpty
        ? Text(
            'Faces Detected: ${_faces.length}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          )
        : Container();
  }

  Widget buildImageDisplay() {
    return _image != null
        ? SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              children: [
                Image.file(_image!), // Display image
                CustomPaint(
                  painter: _imageUi != null ? FacePainter(_imageUi!, _faces) : null,
                  child: Container(),
                ),
              ],
            ),
          )
        : const Icon(Icons.image, size: 150);
  }

  Widget buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => chooseOrCaptureImage(ImageSource.camera),
          child: const Text('Capture From Camera'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => chooseOrCaptureImage(ImageSource.gallery),
          child: const Text('Choose From Gallery'),
        ),
      ],
    );
  }

  Widget buildClearButton() {
    return ElevatedButton(
      onPressed: clearImage,
      child: const Text('Clear Image'),
    );
  }
}
