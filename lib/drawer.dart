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

  bool _themeLight = false;
  String _themeString = "Light";

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return WeatherPage();
      case 1:
        return NotamPage();
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop();
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
                          child: Text(_themeString),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                        ),
                        Flexible(
                          child: Switch(
                            value: _themeLight,
                            onChanged: (bool value) {
                              setState(() {
                                _themeLight = value;
                                value == false ? _themeString = "LIGHT" : _themeString = "DARK";
                              }); },
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
