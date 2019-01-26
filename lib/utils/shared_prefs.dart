import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesModel {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  final String _kWeatherInformationPrefs = "wx_information";
  final String _kWeatherUserInputPrefs = "wx_userInput";

  /// ----------------------------
  /// Methods for weather requests
  /// ----------------------------
  Future<String> getWeatherInformation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kWeatherInformationPrefs) ?? false;
  }

  Future<bool> setWeatherInformation(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kWeatherInformationPrefs, value);
  }

  Future<String> getWeatherUserInput() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kWeatherUserInputPrefs) ?? false;
  }

  Future<bool> setWeatherUserInput(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kWeatherUserInputPrefs, value);
  }

}