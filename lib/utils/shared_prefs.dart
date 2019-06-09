import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesModel {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  final String _kWeatherInformationPrefs = "wx_information";
  final String _kWeatherUserInputPrefs = "wx_userInput";

  final String _kNotamInformationPrefs = "notam_information";
  final String _kNotamUserInputPrefs = "notam_userInput";
  final String _kNotamRequestedAirportsPrefs = "notam_requestedAirports";
  final String _kNotamScrollListPrefs = "notam_scrollList";
  final String _kNotamRequestedTimePrefs = "notam_requestTime";
  final String _kNotamCategorySortingPrefs = "notam_categorySorting";

  /// ----------------------------
  /// Methods for weather requests
  /// ----------------------------
  Future<String> getWeatherInformation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kWeatherInformationPrefs) ?? "";
  }

  Future<bool> setWeatherInformation(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kWeatherInformationPrefs, value);
  }

  Future<String> getWeatherUserInput() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kWeatherUserInputPrefs) ?? "";
  }

  Future<bool> setWeatherUserInput(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kWeatherUserInputPrefs, value);
  }

  /// ----------------------------
  /// Methods for notam requests
  /// ----------------------------
  Future<String> getNotamInformation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kNotamInformationPrefs) ?? "";
  }

  Future<bool> setNotamInformation(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kNotamInformationPrefs, value);
  }

  // ***********
  Future<String> getNotamUserInput() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kNotamUserInputPrefs) ?? "";
  }

  Future<bool> setNotamUserInput(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kNotamUserInputPrefs, value);
  }

  // ***********
  Future<List<String>> getNotamRequestedAirports() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kNotamRequestedAirportsPrefs) ?? List<String>();
  }

  Future<bool> setNotamRequestedAirports(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_kNotamRequestedAirportsPrefs, value);
  }

  // ***********
  Future<List<String>> getNotamScrollList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kNotamScrollListPrefs) ?? List<String>();
  }

  Future<bool> setNotamScrollList(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_kNotamScrollListPrefs, value);
  }

  // ***********
  Future<String> getNotamRequestedTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kNotamRequestedTimePrefs) ?? "";
  }

  Future<bool> setNotamRequestedTime(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kNotamRequestedTimePrefs, value);
  }

  // ***********
  Future<bool> getNotamCategorySorting() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNotamCategorySortingPrefs) ?? false;
  }

  Future<bool> setNotamCategorySorting(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_kNotamCategorySortingPrefs, value);
  }

}