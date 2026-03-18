import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ai_service.dart';
import 'notification_service.dart';

class ContextService extends GetxService {
  var userActivity = "Calibrating...".obs;
  var currentSpeed = 0.0.obs;

  var stationarySeconds = 0.obs;
  var walkingSeconds = 0.obs;
  var handSeconds = 0.obs;

  final storage = GetStorage();
  final AIService _aiService = Get.find<AIService>();
  StreamSubscription? _accelSub;
  DateTime _startTime = DateTime.now();
  Timer? _stationaryAlertTimer;

  @override
  void onInit() {
    super.onInit();

    // --- STEP 1: DAILY RESET CHECK ---
    _checkDailyReset();

    stationarySeconds.value = storage.read('s_sec') ?? 0;
    walkingSeconds.value = storage.read('w_sec') ?? 0;
    handSeconds.value = storage.read('h_sec') ?? 0;
    _initEngine();
  }

  // Naya function jo date check karega
  void _checkDailyReset() {
    String today = DateTime.now().toString().split(' ')[0]; // Result: "2026-03-18"
    String? lastDate = storage.read('last_active_date');

    if (lastDate != null && lastDate != today) {
      resetStorage(); // Purana data urado agar din badal gaya
    }
    storage.write('last_active_date', today);
  }

  Future<void> _initEngine() async {
    await [
      Permission.location,
      Permission.sensors,
      Permission.notification
    ].request();
    _startListening();
  }

  void _startListening() {
    _accelSub = accelerometerEvents.listen((AccelerometerEvent event) {
      double x = event.x.abs();
      double y = event.y.abs();
      double z = (event.z.abs() - 9.8).abs();
      double motion = x + y + z;

      String detected = (motion < 0.8) ? "Stationary (Table)" : (motion < 4.5) ? "Device in Hand" : "Walking / Active";

      if (detected != userActivity.value) {
        _saveCurrentTime();
        _handleNotificationLogic(detected);
        userActivity.value = detected;
        _aiService.getContextAdvice(detected, currentSpeed.value);
      }
    });
  }

  void _handleNotificationLogic(String newActivity) {
    if (newActivity.contains("Stationary")) {
      _stationaryAlertTimer?.cancel();
      _stationaryAlertTimer = Timer(const Duration(seconds: 15), () {
        if (userActivity.value.contains("Stationary")) {
          NotificationService.showNotification(
              "AI Wellness Alert! 🚨",
              "You've been stationary for a while. How about a quick walk to stay active?"
          );
        }
      });
    } else {
      _stationaryAlertTimer?.cancel();
    }
  }

  void _saveCurrentTime() {
    DateTime now = DateTime.now();
    int spent = now.difference(_startTime).inSeconds;

    if (userActivity.value.contains("Stationary")) {
      stationarySeconds.value += spent;
      storage.write('s_sec', stationarySeconds.value);
    } else if (userActivity.value.contains("Walking")) {
      walkingSeconds.value += spent;
      storage.write('w_sec', walkingSeconds.value);
    } else if (userActivity.value.contains("Hand")) {
      handSeconds.value += spent;
      storage.write('h_sec', handSeconds.value);
    }
    _startTime = now;
  }

  void resetStorage() {
    // Sirf activity data clear karein, user name ya date nahi
    storage.write('s_sec', 0);
    storage.write('w_sec', 0);
    storage.write('h_sec', 0);
    stationarySeconds.value = 0;
    walkingSeconds.value = 0;
    handSeconds.value = 0;
    _stationaryAlertTimer?.cancel();
  }

  @override
  void onClose() {
    _accelSub?.cancel();
    _stationaryAlertTimer?.cancel();
    super.onClose();
  }
}