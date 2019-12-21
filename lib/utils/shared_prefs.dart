import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SharedPreferencesModel {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  final String _kAppThemePrefs = "app_theme";
  final String _kAppVersionPrefs = "app_version";

  final String _kSettingsOpenSpecificSection = "settings_openSpecificSection";
  final String _kSettingsLastUsedSection = "settings_lastUsedSection";
  final String _kSettingsShowHeaders = "settings_showHeaders";

  final String _kWeatherInformationPrefs = "wx_information";
  final String _kWeatherUserInputPrefs = "wx_userInput";
  final String _kWeatherRequestedAirportsPrefs = "wx_requestedAirports";
  final String _kWeatherHoursBeforePrefs = "wx_hoursBefore";

  final String _kNotamInformationPrefs = "notam_information";
  final String _kNotamUserInputPrefs = "notam_userInput";
  final String _kNotamRequestedAirportsPrefs = "notam_requestedAirports";
  final String _kNotamScrollListPrefs = "notam_scrollList";
  final String _kNotamRequestedTimePrefs = "notam_requestTime";
  final String _kNotamCategorySortingPrefs = "notam_categorySorting";

  final String _kConditionModelPrefs = "condition_model";
  final String _kConditionInputPrefs = "condition_input";

  final String _kTemperatureValuesPrefs = "temperature_values";
  final String _kTemperatureCorrectionsPrefs = "temperature_corrections";
  final String _kTemperatureTempPrefs = "temperature_temp";
  final String _kTemperatureElevPrefs = "temperature_elev";
  final String _kTemperatureRoundPrefs = "temperature_round";

  final String _kFavouritePrefs = "favourites_list";



  /// ----------------------------
  /// Methods for app theme
  /// ----------------------------
  Future<String> getAppTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAppThemePrefs) ?? "";
  }

  Future<bool> setAppTheme(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kAppThemePrefs, value);
  }

  /// ----------------------------
  /// Methods for app version
  /// ----------------------------
  Future<String> getAppVersion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAppVersionPrefs) ?? "";
  }

  Future<bool> setAppVersion(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kAppVersionPrefs, value);
  }

  /// ----------------------------
  /// Methods for app settings
  /// ----------------------------
  Future<String> getSettingsOpenSpecificSection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSettingsOpenSpecificSection) ?? "99";
  }

  Future<bool> setSettingsOpenSpecificSection(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kSettingsOpenSpecificSection, value);
  }

  // ***********
  Future<String> getSettingsLastUsedSection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSettingsLastUsedSection) ?? "0";
  }

  Future<bool> setSettingsLastUsedSection(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kSettingsLastUsedSection, value);
  }

  // ***********
  Future<bool> getSettingsShowHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSettingsShowHeaders) ?? true;
  }

  Future<bool> setSettingsShowHeaders(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_kSettingsShowHeaders, value);
  }

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

  // ***********
  Future<String> getWeatherUserInput() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kWeatherUserInputPrefs) ?? "";
  }

  Future<bool> setWeatherUserInput(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kWeatherUserInputPrefs, value);
  }

  // ***********
  Future<List<String>> getWeatherRequestedAirports() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kWeatherRequestedAirportsPrefs) ?? List<String>();
  }

  Future<bool> setWeatherRequestedAirports(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_kWeatherRequestedAirportsPrefs, value);
  }

  // ***********
  Future<int> getWeatherHoursBefore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kWeatherHoursBeforePrefs) ?? 0;
  }

  Future<bool> setWeatherHoursBefore(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_kWeatherHoursBeforePrefs, value);
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
    return prefs.getBool(_kNotamCategorySortingPrefs) ?? true;
  }

  Future<bool> setNotamCategorySorting(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_kNotamCategorySortingPrefs, value);
  }

  /// -------------------------------
  /// Methods for condition requests
  /// -------------------------------
  Future<String> getConditionModel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kConditionModelPrefs) ?? "";
  }

  Future<bool> setConditionModel(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kConditionModelPrefs, value);
  }

  // ***********
  Future<String> getConditionInput() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kConditionInputPrefs) ?? "";
  }

  Future<bool> setConditionInput(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kConditionInputPrefs, value);
  }


/// --------------------------------------------
/// Methods for temperature corrections requests
/// --------------------------------------------
  Future<List<String>> getTemperatureValueList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kTemperatureValuesPrefs) ?? List<String>();
  }

  Future<bool> setTemperatureValueList(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_kTemperatureValuesPrefs, value);
  }

  // ***********
  Future<List<String>> getTemperatureCorrectionList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kTemperatureCorrectionsPrefs) ?? List<String>();
  }

  Future<bool> setTemperatureCorrectionList(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_kTemperatureCorrectionsPrefs, value);
  }

  // ***********
  Future<int> getTemperatureTemp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kTemperatureTempPrefs) ?? 0;
  }

  Future<bool> setTemperatureTemp(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_kTemperatureTempPrefs, value);
  }

  // ***********
  Future<int> getTemperatureElev() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kTemperatureElevPrefs) ?? 0;
  }

  Future<bool> setTemperatureElev(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_kTemperatureElevPrefs, value);
  }

  // ***********
  Future<int> getTempRound() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kTemperatureRoundPrefs) ?? 0;
  }

  Future<bool> setTempRound(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_kTemperatureRoundPrefs, value);
  }



  /// --------------------------------------------
  /// Methods for favourites
  /// --------------------------------------------

  Future<List<String>> getFavourites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kFavouritePrefs) ?? List<String>();
  }

  Future<bool> setFavourites(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_kFavouritePrefs, value);
  }


}