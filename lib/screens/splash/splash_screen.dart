import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity1 = 0.0;
  double _opacity2 = 0.0;

  @override
  void initState() {
    super.initState();

    print('SplashScreen initialized'); // Debug print

    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _opacity1 = 1.0;
        });
        print('First text animation started - JELAJAH'); // Debug print
      }
    });

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _opacity2 = 1.0;
        });
        print('Second text animation started - NUSANTARA'); // Debug print
      }
    });

    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        print('Navigating to LoginScreen'); // Debug print
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1A824),
      body: SafeArea(
        child: Stack(
          children: [
            // Bottom wave background
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: WaveClipperBottom(),
                child: Container(
                  color: const Color(0xFFF6F2E5),
                  height: MediaQuery.of(context).size.height * 3 / 4,
                  width: double.infinity,
                ),
              ),
            ),

            // Main content with text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: _opacity1,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    child: const Text(
                      "JELAJAH",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        fontFamily: "NicoMoji",
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedOpacity(
                    opacity: _opacity2,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    child: const Text(
                      "NUSANTARA",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        fontFamily: "NicoMoji",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top wave
            Align(
              alignment: Alignment.topCenter,
              child: ClipPath(
                clipper: WaveClipperTop(),
                child: Container(
                  color: const Color(0xFFF6F2E5),
                  height: 100,
                  width: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveClipperBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 4,
      size.height - 70,
      size.width / 2,
      size.height - 50,
    );
    path.quadraticBezierTo(
      3 / 4 * size.width,
      size.height - 30,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class WaveClipperTop extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height - 70);
    path.quadraticBezierTo(
      size.width * 3 / 5,
      size.height + 5,
      size.width * 3 / 5,
      size.height - 50,
    );
    path.quadraticBezierTo(
      size.width * 3 / 5,
      size.height - 120,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
