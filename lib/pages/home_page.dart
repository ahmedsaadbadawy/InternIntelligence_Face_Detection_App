import 'package:flutter/material.dart';
import 'choose_or_capture_picture.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(),
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      child: SizedBox(
        height: 250,
        child: Image.asset('assets/images/face_detection_icon.png'),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      child: Center(
        child: SizedBox(
          width: 350,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChooseOrCapturePicture()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06402b),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Go Recognize',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
