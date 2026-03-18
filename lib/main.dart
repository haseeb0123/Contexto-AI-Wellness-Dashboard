import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_storage/get_storage.dart';
import 'services/context_service.dart';
import 'services/ai_service.dart';
import 'services/notification_service.dart';
import 'controllers/profile_controller.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await NotificationService.init();

  Get.put(ProfileController());
  Get.put(AIService());
  Get.put(ContextService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Contexto AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/home', page: () => const ContextHomePage()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
      ],
    );
  }
}

// --- SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      Get.offAllNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_m6cuL6.json',
              height: 250,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_awesome, size: 100, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            Text("CONTEXTO AI",
                style: GoogleFonts.orbitron(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 5)),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}

// --- HOME PAGE ---
class ContextHomePage extends StatelessWidget {
  const ContextHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final contextService = Get.find<ContextService>();
    final aiService = Get.find<AIService>();
    final profileController = Get.find<ProfileController>();

    final deepReport = "".obs;
    final isReportLoading = false.obs;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(profileController),
                const SizedBox(height: 30),

                // Updated Activity Card with Glow
                _buildActivityCard(contextService, profileController),

                const SizedBox(height: 30),

                _buildAISection(aiService),

                const SizedBox(height: 30),

                Text("ACTIVITY DISTRIBUTION",
                    style: GoogleFonts.orbitron(fontSize: 12, color: Colors.blueAccent, letterSpacing: 2)),
                const SizedBox(height: 15),

                _buildPieChart(contextService),

                const SizedBox(height: 30),
                Text("AI PERFORMANCE AUDIT",
                    style: GoogleFonts.orbitron(fontSize: 12, color: Colors.amberAccent, letterSpacing: 2)),
                const SizedBox(height: 15),
                _buildDeepAuditSection(aiService, contextService, deepReport, isReportLoading),

                const SizedBox(height: 30),

                Row(
                  children: [
                    _buildStatCard("Active", Icons.bolt, Colors.orangeAccent),
                    const SizedBox(width: 15),
                    _buildStatCard("Focus", Icons.psychology, Colors.purpleAccent),
                  ],
                ),
                const SizedBox(height: 20),

                Center(
                  child: TextButton.icon(
                    onPressed: () => contextService.resetStorage(),
                    icon: const Icon(Icons.refresh, color: Colors.white54, size: 16),
                    label: const Text("Reset History", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ProfileController pController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome Back,", style: TextStyle(color: Colors.white70, fontSize: 14)),
            Obx(() => Text(
              pController.userName.value,
              style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            )),
          ],
        ),
        GestureDetector(
          onTap: () => Get.toNamed('/profile'),
          child: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white)
          ),
        )
      ],
    );
  }

  Widget _buildActivityCard(ContextService contextService, ProfileController profileController) {
    return Obx(() {
      // Goal logic
      double walkingMinutes = contextService.walkingSeconds.value / 60;
      bool isGoalReached = walkingMinutes >= profileController.dailyGoal.value;

      return GlassmorphicContainer(
        width: double.infinity, height: 220, borderRadius: 30, blur: 20, alignment: Alignment.center, border: 2,
        linearGradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
        // Border turns Green when goal is reached
        borderGradient: LinearGradient(
            colors: isGoalReached
                ? [Colors.greenAccent, Colors.green.withOpacity(0.5)]
                : [Colors.blueAccent.withOpacity(0.5), Colors.purpleAccent.withOpacity(0.5)]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoalReached)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text("🏆 GOAL REACHED", style: GoogleFonts.orbitron(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              ),
            SizedBox(
              height: 100,
              child: Lottie.network(
                _getLottieAsset(contextService.userActivity.value),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.bolt, size: 60, color: Colors.white),
              ),
            ),
            Text(contextService.userActivity.value.toUpperCase(),
                style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
            Text("${contextService.currentSpeed.value.toStringAsFixed(1)} km/h",
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    });
  }

  Widget _buildAISection(AIService aiService) {
    return Obx(() => Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          if (aiService.isLoading.value) const LinearProgressIndicator(color: Colors.blueAccent)
          else const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
          const SizedBox(height: 10),
          Text(aiService.aiSuggestion.value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    ));
  }

  Widget _buildDeepAuditSection(AIService aiService, ContextService contextService, RxString deepReport, RxBool isLoading) {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          if (deepReport.value.isEmpty)
            const Text("Ready to analyze your daily habits? Click below for a deep AI audit.",
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13))
          else
            Text(deepReport.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: isLoading.value ? null : () async {
              isLoading.value = true;
              deepReport.value = await aiService.getDeepAnalysis(
                  contextService.stationarySeconds.value,
                  contextService.walkingSeconds.value,
                  contextService.handSeconds.value
              );
              isLoading.value = false;
            },
            icon: isLoading.value
                ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent))
                : const Icon(Icons.insights, size: 18),
            label: Text(isLoading.value ? "ANALYZING..." : "GENERATE AI REPORT"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent.withOpacity(0.15),
              foregroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildPieChart(ContextService service) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              double s = (service.stationarySeconds.value).toDouble();
              double w = (service.walkingSeconds.value).toDouble();
              double h = (service.handSeconds.value).toDouble();
              double total = s + w + h;

              return PieChart(
                PieChartData(
                  sectionsSpace: 5,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(value: s == 0 && total == 0 ? 1 : s, color: Colors.blueAccent, title: total == 0 ? "" : "${((s/total)*100).toInt()}%", radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    PieChartSectionData(value: w, color: Colors.orangeAccent, title: total == 0 ? "" : "${((w/total)*100).toInt()}%", radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    PieChartSectionData(value: h, color: Colors.purpleAccent, title: total == 0 ? "" : "${((h/total)*100).toInt()}%", radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegend(Colors.blueAccent, "Stationary"),
              _buildLegend(Colors.orangeAccent, "Walking"),
              _buildLegend(Colors.purpleAccent, "In Hand"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
        child: Row(children: [Icon(icon, color: color, size: 24), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 12))]),
      ),
    );
  }

  String _getLottieAsset(String activity) {
    if (activity.contains("Walking")) return 'https://lottie.host/80709b1f-e053-4713-911b-c75267a536b0/M29Z4S6f5A.json';
    if (activity.contains("Hand")) return 'https://lottie.host/880313f8-80e9-4676-9289-42b477647225/mSgEImI6i6.json';
    return 'https://lottie.host/d147496c-8515-4673-8686-2182103f1505/v3Gg7z7hL8.json';
  }
}