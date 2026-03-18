import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfileController extends GetxController {
  final storage = GetStorage();

  var userName = "AI Explorer".obs;
  var dailyGoal = 30.obs; // Minutes mein

  @override
  void onInit() {
    super.onInit();
    // Storage se purana naam aur goal uthao
    userName.value = storage.read('user_name') ?? "AI Explorer";
    dailyGoal.value = storage.read('daily_goal') ?? 30;
  }

  void updateProfile(String name, int goal) {
    userName.value = name;
    dailyGoal.value = goal;
    storage.write('user_name', name);
    storage.write('daily_goal', goal);
  }
}