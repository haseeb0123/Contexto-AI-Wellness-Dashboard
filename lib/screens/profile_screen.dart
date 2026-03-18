import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController pController = Get.find<ProfileController>();

    // Controllers for inputs
    final TextEditingController nameEdit = TextEditingController(text: pController.userName.value);
    final TextEditingController goalEdit = TextEditingController(text: pController.dailyGoal.value.toString());

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("USER PROFILE", style: GoogleFonts.orbitron(fontSize: 16, letterSpacing: 2)),
          centerTitle: true
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const CircleAvatar(
                radius: 55,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person_outline, size: 60, color: Colors.white)
            ),
            const SizedBox(height: 40),

            // --- NAME INPUT ---
            TextField(
              controller: nameEdit,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Full Name",
                labelStyle: const TextStyle(color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.badge_outlined, color: Colors.blueAccent),
              ),
            ),

            const SizedBox(height: 20),

            // --- GOAL INPUT (Seconds to Minutes logic ke liye zaroori hai) ---
            TextField(
              controller: goalEdit,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Daily Walking Goal (Minutes)",
                labelStyle: const TextStyle(color: Colors.orangeAccent),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.directions_walk, color: Colors.orangeAccent),
                helperText: "Dashboard will glow green once you hit this goal.",
                helperStyle: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),

            const SizedBox(height: 40),

            // --- SAVE BUTTON ---
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                onPressed: () {
                  // Parsing goal safely
                  int newGoal = int.tryParse(goalEdit.text) ?? 30;

                  pController.updateProfile(nameEdit.text, newGoal);

                  Get.back(); // Wapas Home par
                  Get.snackbar(
                    "Profile Updated",
                    "Settings applied successfully!",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blueAccent.withOpacity(0.8),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(15),
                    borderRadius: 10,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                  );
                },
                child: Text("SAVE SETTINGS", style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
            )
          ],
        ),
      ),
    );
  }
}