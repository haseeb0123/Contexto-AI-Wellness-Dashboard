import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 seconds baad home page par bhej dega
    Future.delayed(const Duration(seconds: 4), () {
      Get.offNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Aesthetic Background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI Floating Robot Animation
            Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_m6cuL6.json',
              height: 300,
            ),
            const SizedBox(height: 20),
            Text(
              "CONTEXTO AI",
              style: GoogleFonts.orbitron(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your Smart Life Companion",
              style: TextStyle(color: Colors.white54, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}