import 'package:flutter/material.dart';
import 'drawer.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';


void main() => runApp(new Cavokator());

class Cavokator extends StatefulWidget {
  @override
  _CavokatorState createState() => _CavokatorState();
}

class _CavokatorState extends State<Cavokator> {

  String _thisAppVersion = "2.0";  // TODO (IMPORTANT): update!
  Brightness _myBrightness = Brightness.light;

  @override
  void initState() {
    super.initState();
    _restoreThemePreferences();
    SharedPreferencesModel().setAppVersion(_thisAppVersion);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cavokator",
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        brightness: _myBrightness,
      ),
      home: DrawerPage(
        changeBrightness: callbackBrightness,
        savedThemeDark: _myBrightness == Brightness.dark ? true : false,
        thisAppVersion: _thisAppVersion,
      ),
    );
  }

  void callbackBrightness(Brightness thisBrightness) {
    setState(() {
      _myBrightness = thisBrightness;
    });
  }

  void _restoreThemePreferences () {
    SharedPreferencesModel().getAppTheme().then((onValue) {
      setState(() {
        _myBrightness = onValue == "DARK" ? Brightness.dark : Brightness.light;
      });
    });
  }

}
