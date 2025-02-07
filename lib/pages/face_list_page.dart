import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/face_model.dart';

class FaceListPage extends StatefulWidget {
  const FaceListPage({super.key});

  @override
  State<FaceListPage> createState() => _FaceListPageState();
}

class _FaceListPageState extends State<FaceListPage> {
  late Future<List<FaceModel>> _facesFuture;

  @override
  void initState() {
    super.initState();
    _facesFuture = DatabaseHelper.instance.getAllFaces();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved Faces'),
        ),
        body: FutureBuilder<List<FaceModel>>(
          future: _facesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No saved faces found.'));
            } else {
              final faces = snapshot.data!;
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: faces.length,
                itemBuilder: (context, index) {
                  final face = faces[index];
                  return GridTile(
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.file(
                            File(face.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(face.name,
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
