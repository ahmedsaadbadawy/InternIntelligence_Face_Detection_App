import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImageUtils {
  static Future<ui.Image> loadImage(File file) async {
    final data = await file.readAsBytes();
    return await decodeImageFromList(data);
  }
}
