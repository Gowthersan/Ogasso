import 'package:shared_preferences/shared_preferences.dart';

class SettingService {
  final String SETTING_ALERT_KEY = "setting-alert-key";
  final String SETTING_WARNING_KEY = "setting-warning-key";

  Future<void> saveSetting({required final int alert, required final int warning}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(SETTING_ALERT_KEY, alert);
    sharedPreferences.setInt(SETTING_WARNING_KEY, warning);
  }

  Future<int> getWarning() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final int? data = sharedPreferences.getInt(SETTING_WARNING_KEY);
    return data ?? 10;
  }

  Future<int> getAlert() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final int? data = sharedPreferences.getInt(SETTING_ALERT_KEY);
    return data ?? 5;
  }
}
