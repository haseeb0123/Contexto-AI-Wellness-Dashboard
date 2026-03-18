import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AIService extends GetxService {
  // 🔐 SECURITY FIX: Key ko ab hum external parameter se uthayenge
  // App run karte waqt: flutter run --define=GROQ_KEY=YOUR_KEY
  static const String _apiKey = String.fromEnvironment('GROQ_KEY', defaultValue: 'YOUR_KEY_HERE');

  final String _url = "https://api.groq.com/openai/v1/chat/completions";

  var aiSuggestion = "Ready to analyze...".obs;
  var isLoading = false.obs;
  DateTime? _lastRequestTime;

  Future<void> getContextAdvice(String activity, double speed) async {
    if (_apiKey == 'YOUR_KEY_HERE') {
      aiSuggestion.value = "Please add API Key to run.";
      return;
    }

    if (_lastRequestTime != null &&
        DateTime.now().difference(_lastRequestTime!).inSeconds < 10) {
      return;
    }

    try {
      isLoading.value = true;
      _lastRequestTime = DateTime.now();

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "user", "content": "Activity: $activity. Give 1 cool short advice (5 words)."}
          ],
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        aiSuggestion.value = data['choices'][0]['message']['content'].trim();
      } else {
        aiSuggestion.value = "AI busy. Try moving again.";
      }
    } catch (e) {
      aiSuggestion.value = "Connection weak. Try again.";
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getDeepAnalysis(int stationary, int walking, int hand) async {
    if (_apiKey == 'YOUR_KEY_HERE') return "API Key Missing.";

    double total = (stationary + walking + hand).toDouble();
    if (total == 0) return "No activity recorded yet. Start moving to get a report!";

    double sPerc = (stationary / total) * 100;
    double wPerc = (walking / total) * 100;

    String prompt = "The user spent ${sPerc.toInt()}% of their time stationary and ${wPerc.toInt()}% walking. Provide a professional, concise health audit (max 30 words) and one actionable advice.";

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [{"role": "user", "content": prompt}],
          "temperature": 0.7,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      }
      return "AI failed to generate report. Try again later.";
    } catch (e) {
      return "Network error. Please check your internet.";
    }
  }
}