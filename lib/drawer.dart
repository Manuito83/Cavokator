import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cavokator_flutter/weather/weather.dart';
import 'package:cavokator_flutter/notam/notam.dart';
import 'package:cavokator_flutter/condition/condition.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';
import 'package:cavokator_flutter/utils/theme_me.dart';

class DrawerItem {
  String title;
  String asset;

  DrawerItem(this.title, this.asset);
}

class DrawerPage extends StatefulWidget {

  final Function changeBrightness;
  final bool savedThemeDark;

  DrawerPage({@required this.changeBrightness, @required this.savedThemeDark});

  final drawerItems = [
    new DrawerItem("Weather", "assets/icons/drawer_wx.png"),
    new DrawerItem("NOTAM", "assets/icons/drawer_notam.png"),
    new DrawerItem("RWY Condition", "assets/icons/drawer_condition.png")
  ];

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  int _selectedDrawerIndex = 0;

  bool _isThemeDark;
  String _switchThemeString = "";

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

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return WeatherPage(
          isThemeDark: _isThemeDark,
          myFloat: myFloat,
          callback: callbackFab,
        );
      case 1:
        return NotamPage(
          isThemeDark: _isThemeDark,
          myFloat: myFloat,
          callback: callbackFab,
        );
      case 2:
        return ConditionPage(
          isThemeDark: _isThemeDark,
          myFloat: myFloat,
          callback: callbackFab,
        );
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
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

  @override
  Widget build(BuildContext context) {
    _isThemeDark = widget.savedThemeDark;
    _switchThemeString = _isThemeDark == true ? "DARK" : "LIGHT";
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var myItem = widget.drawerItems[i];
      var myBackgroundColor = Colors.transparent;  // Transparent
      if (i == _selectedDrawerIndex){
        myBackgroundColor = Colors.grey[200];
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
              selected: i == _selectedDrawerIndex,
              onTap: () => _onSelectItem(i),
            ),
          )
        ),
      );
    }

    return Scaffold(
//      appBar: AppBar(
//        title: Text(widget.drawerItems[_selectedDrawerIndex].title),
//      ),
      floatingActionButton: myFloat,
      drawer: Drawer(
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

            Column(children: drawerOptions)
          ],
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );

  }




}
