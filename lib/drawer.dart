import 'dart:async';
import 'package:cavokator_flutter/favourites/favourites.dart';
import 'package:cavokator_flutter/temperature/temperature.dart';
import 'package:cavokator_flutter/utils/changelog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cavokator_flutter/weather/weather.dart';
import 'package:cavokator_flutter/notam/notam.dart';
import 'package:cavokator_flutter/condition/condition.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';
import 'package:cavokator_flutter/utils/theme_me.dart';
import 'package:cavokator_flutter/settings/settings.dart';
import 'package:cavokator_flutter/about/about.dart';


class DrawerItem {
  String title;
  String asset;

  DrawerItem(this.title, this.asset);
}


class DrawerPage extends StatefulWidget {

  final Function changeBrightness;
  final bool savedThemeDark;
  final String thisAppVersion;

  DrawerPage({@required this.changeBrightness, @required this.savedThemeDark,
              @required this.thisAppVersion});

  final drawerItems = [
    new DrawerItem("Weather", "assets/icons/drawer_wx.png"),
    new DrawerItem("NOTAM", "assets/icons/drawer_notam.png"),
    new DrawerItem("RWY Condition", "assets/icons/drawer_condition.png"),
    new DrawerItem("TEMP Corrections", "assets/icons/drawer_temperature.png"),
    new DrawerItem("Favourites", "assets/icons/drawer_favourites.png"),
    new DrawerItem("Settings", "assets/icons/drawer_settings.png"),
    new DrawerItem("About", "assets/icons/drawer_about.png"),
  ];

  @override
  _DrawerPageState createState() => _DrawerPageState();
  }


class _DrawerPageState extends State<DrawerPage> {
  int _activeDrawerIndex = 0;
  int _selected = 0;
  bool _sharedPreferencesReady = false;

  bool _isThemeDark;
  bool _showHeaderImages = true;
  String _switchThemeString = "";

  double _scrollPositionWeather = 0;
  double _scrollPositionNotam = 0;

  bool _hideBottomNavBar = false;
  bool _bottomWeatherButtonDisabled = false;
  bool _bottomNotamButtonDisabled = false;
  bool _swipeSections = true;  // TODO (maybe?): setting to deactivate this?

  PageController _myPageController;


  Widget myFloat = SpeedDial(
    overlayColor: Colors.black,
    overlayOpacity: 0.5,
    elevation: 8.0,
    shape: CircleBorder(),
    visible: false,
  );


  void callbackFab(Widget fab) {
    setState(() {
      this.myFloat = fab;
    });
  }

  @override
  void initState() {
    super.initState();

    _handleVersionNumber();

    _restoreSharedPreferences().then((value) {
      setState(() {
        _sharedPreferencesReady = true;
      });
    });
  }


  @override
  void dispose() {
    _myPageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    _isThemeDark = widget.savedThemeDark;
    _switchThemeString = _isThemeDark == true ? "DARK" : "LIGHT";
    var drawerOptions = <Widget>[];

    for (var i = 0; i < widget.drawerItems.length; i++) {
      var myItem = widget.drawerItems[i];
      var myBackgroundColor = Colors.transparent;  // Transparent
      if (i == _selected){
        myBackgroundColor = Colors.grey[200];
      }

      // Adding divider just before FAVOURITES (3 before end)
      if (i == widget.drawerItems.length - 3) {
        drawerOptions.add(Divider());
      }

      drawerOptions.add(
        ListTileTheme(
            selectedColor: Colors.red,
            iconColor: ThemeMe.apply(_isThemeDark, DesiredColor.MainText),
            textColor: ThemeMe.apply(_isThemeDark, DesiredColor.MainText),
            child: Ink(
              color: myBackgroundColor,
              child: ListTile(
                leading: ImageIcon(AssetImage(myItem.asset)),
                title: Text(myItem.title),
                selected: i == _selected,
                onTap: () => _onSelectItem(i),
              ),
            )
        ),
      );
    }

    return Scaffold(
      floatingActionButton: myFloat,
      drawer: Drawer(
        elevation: 2, // This avoids shadow over SafeArea
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 300,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Flexible(
                        child: Image(
                          image: AssetImage('assets/images/appicon.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      Text(
                        'CAVOKATOR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: Text(_switchThemeString),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                            ),
                            Flexible(
                              child: Switch(
                                value: _isThemeDark,
                                onChanged: (bool value) {
                                  _handleThemeChanged(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(children: drawerOptions),
          ],
        ),
      ),
      body: _getDrawerItemWidget(),
      bottomNavigationBar: _bottomNavBar(),
    );
  }


  Widget _getDrawerItemWidget() {
    if (_sharedPreferencesReady) {

      // This shared pref. needs to go here or else won't update
      // live if we change the configuration in Settings
      SharedPreferencesModel().getSettingsShowHeaders().then((onValue) {
        _showHeaderImages = onValue;
      });

      _myPageController = PageController (
        initialPage: (_activeDrawerIndex == 0) ? 0 : 1,
        keepPage: false,
      );

      switch (_activeDrawerIndex) {
        case 0:
          if (_swipeSections) {
            return PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _myPageController,
              children: <Widget>[
                WeatherPage(
                  isThemeDark: _isThemeDark,
                  myFloat: myFloat,
                  callback: callbackFab,
                  showHeaders: _showHeaderImages,
                  hideBottomNavBar: _turnBottomNavBarOff,
                  showBottomNavBar: _turnBottomNavBarOn,
                  recalledScrollPosition: _scrollPositionWeather,
                  notifyScrollPosition: _setWeatherScrollPosition,
                ),
                NotamPage(
                  isThemeDark: _isThemeDark,
                  myFloat: myFloat,
                  callback: callbackFab,
                  showHeaders: _showHeaderImages,
                  hideBottomNavBar: _turnBottomNavBarOff,
                  showBottomNavBar: _turnBottomNavBarOn,
                  recalledScrollPosition: _scrollPositionNotam,
                  notifyScrollPosition: _setNotamScrollPosition,
                ),
              ],
            );
          } else {
            return WeatherPage(
              isThemeDark: _isThemeDark,
              myFloat: myFloat,
              callback: callbackFab,
              showHeaders: _showHeaderImages,
              hideBottomNavBar: _turnBottomNavBarOff,
              showBottomNavBar: _turnBottomNavBarOn,
              recalledScrollPosition: _scrollPositionWeather,
              notifyScrollPosition: _setWeatherScrollPosition,
            );
          }
          break;
        case 1:
          if (_swipeSections) {
            return PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _myPageController,
              children: <Widget>[
                WeatherPage(
                  isThemeDark: _isThemeDark,
                  myFloat: myFloat,
                  callback: callbackFab,
                  showHeaders: _showHeaderImages,
                  hideBottomNavBar: _turnBottomNavBarOff,
                  showBottomNavBar: _turnBottomNavBarOn,
                  recalledScrollPosition: _scrollPositionWeather,
                  notifyScrollPosition: _setWeatherScrollPosition,
                ),
                NotamPage(
                  isThemeDark: _isThemeDark,
                  myFloat: myFloat,
                  callback: callbackFab,
                  showHeaders: _showHeaderImages,
                  hideBottomNavBar: _turnBottomNavBarOff,
                  showBottomNavBar: _turnBottomNavBarOn,
                  recalledScrollPosition: _scrollPositionNotam,
                  notifyScrollPosition: _setNotamScrollPosition,
                ),
              ],
            );
          } else {
            return NotamPage(
              isThemeDark: _isThemeDark,
              myFloat: myFloat,
              callback: callbackFab,
              showHeaders: _showHeaderImages,
              hideBottomNavBar: _turnBottomNavBarOff,
              showBottomNavBar: _turnBottomNavBarOn,
              recalledScrollPosition: _scrollPositionNotam,
              notifyScrollPosition: _setNotamScrollPosition,
            );
          }
          break;
        case 2:
          return ConditionPage(
            isThemeDark: _isThemeDark,
            myFloat: myFloat,
            callback: callbackFab,
            showHeaders: _showHeaderImages,
          );
        case 3:
          return TemperaturePage(
            isThemeDark: _isThemeDark,
            myFloat: myFloat,
            callback: callbackFab,
            showHeaders: _showHeaderImages,
          );
        case 4:
          return FavouritesPage(
            isThemeDark: _isThemeDark,
            myFloat: myFloat,
            callback: callbackFab,
          );
        case 5:
          return SettingsPage(
            isThemeDark: _isThemeDark,
            myFloat: myFloat,
            callback: callbackFab,
            showHeaders: _showHeaderImages,
          );
        case 6:
          return AboutPage(
            isThemeDark: _isThemeDark,
            myFloat: myFloat,
            callback: callbackFab,
            thisAppVersion: widget.thisAppVersion,
          );
        default:
          return new Text("Error");
      }
    }
    return null;
  }


  _onSelectItem(int index) {
    if (index == 1 && _selected == 0) {
      _myPageController.animateToPage(
          1,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut);
    } else if (index == 0 && _selected == 1) {
      _myPageController.animateToPage(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut);
    }

    setState(() {
      _activeDrawerIndex = index;
      _selected = index;
    });

    Navigator.of(context).pop();
  }


  _handleThemeChanged(bool newValue) {
    setState(() {
      _isThemeDark = newValue;
      _switchThemeString = (newValue == true) ? "DARK" : "LIGHT";
      if (newValue == true) {
        widget.changeBrightness(Brightness.dark);
        SharedPreferencesModel().setAppTheme("DARK");
      } else {
        widget.changeBrightness(Brightness.light);
        SharedPreferencesModel().setAppTheme("LIGHT");
      }
    });
  }


  Widget _bottomNavBar () {

    if (_hideBottomNavBar) {
      return null;
    }

    if (_activeDrawerIndex == 0 || _activeDrawerIndex == 1){
      return Container(
        height: 40,
        decoration: new BoxDecoration(
          border: Border(
            top: BorderSide(
                color: ThemeMe.apply(_isThemeDark, DesiredColor.MainText),
                width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: ImageIcon(
                AssetImage("assets/icons/drawer_wx.png"),
                color: (_selected == 0)
                    ? ThemeMe.apply(_isThemeDark, DesiredColor.MagentaCategory)
                    : ThemeMe.apply(_isThemeDark, DesiredColor.MainText),
              ),
              onPressed: ()  {
                if (!_bottomWeatherButtonDisabled) {
                  _bottomNotamButtonDisabled = true;
                  _bottomWeatherButtonDisabled = true;
                  _myPageController.animateToPage(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                  setState(() {
                    _selected = 0;
                  });
                  Future.delayed(Duration(milliseconds: 750), () {
                    _bottomNotamButtonDisabled = false;
                    _bottomWeatherButtonDisabled = false;
                  });
                }
              },
            ),
            IconButton(
              icon: ImageIcon(
                AssetImage("assets/icons/drawer_notam.png"),
                color: (_selected == 1)
                    ? ThemeMe.apply(_isThemeDark, DesiredColor.MagentaCategory)
                    : ThemeMe.apply(_isThemeDark, DesiredColor.MainText),
              ),
              onPressed: ()  {
                if (!_bottomNotamButtonDisabled) {
                  _bottomNotamButtonDisabled = true;
                  _bottomWeatherButtonDisabled = true;
                  _myPageController.animateToPage(
                      1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut
                  );
                  setState(() {
                    _selected = 1;
                  });
                  Future.delayed(Duration(milliseconds: 750), () {
                    _bottomNotamButtonDisabled = false;
                    _bottomWeatherButtonDisabled = false;
                  });
                }
              },
            ),
          ],
        ),
      );
    } else {
      return null;
    }
  }


  Future<Null> _restoreSharedPreferences() async {
    var lastUsed;
    await SharedPreferencesModel().getSettingsLastUsedSection().then((onLastUsedValue) {
      lastUsed = int.parse(onLastUsedValue);
    });

    await SharedPreferencesModel().getSettingsOpenSpecificSection().then((onValue) async {
      var savedSelection = int.parse(onValue);
      if (savedSelection == 99) {
        // Open last-recalled page
        _activeDrawerIndex = _selected = lastUsed;
      } else {
        // Open specific (user chosen) page
        _activeDrawerIndex = _selected = int.parse(onValue);
      }
    });
  }


  void _handleVersionNumber () {
    String savedAppVersion;
    SharedPreferencesModel().getAppVersion().then((onValue) {
      savedAppVersion = onValue;
      if (savedAppVersion != widget.thisAppVersion) {
        _showChangeLogDialog(context);
      }
    });
  }


  void _showChangeLogDialog(BuildContext context) {
    showDialog (
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return ChangeLog(appVersion: widget.thisAppVersion);
      }
    );
  }


  void _turnBottomNavBarOff() {
    setState(() {
      _hideBottomNavBar = true;
    });
  }


  void _turnBottomNavBarOn() {
    setState(() {
      _hideBottomNavBar = false;
    });
  }


  void _setWeatherScrollPosition(double position){
    _scrollPositionWeather = position;
  }


  void _setNotamScrollPosition(double position){
    _scrollPositionNotam = position;
  }

}
