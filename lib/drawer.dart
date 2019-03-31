import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cavokator_flutter/weather/weather.dart';
import 'package:cavokator_flutter/notam/notam.dart';

class DrawerItem {
  String title;
  String asset;

  DrawerItem(this.title, this.asset);
}

class DrawerPage extends StatefulWidget {
  final drawerItems = [
    new DrawerItem("Weather", "assets/icons/drawer_wx.png"),
    new DrawerItem("NOTAM", "assets/icons/drawer_wx.png")
  ];

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  int _selectedDrawerIndex = 0;

  bool _isThemeDark = false;
  String _switchThemeString = "Dark";

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return WeatherPage(
          isThemeDark: _isThemeDark,
        );
      case 1:
        return NotamPage(
          isThemeDark: _isThemeDark,
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
      _switchThemeString = (newValue == false) ? "LIGHT" : "DARK";
    });
  }

  @override
  Widget build(BuildContext context) {
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('CAVOKATOR'),
                    Text('CAVOKATOR 2'),
                    Row(
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
                  ],
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
