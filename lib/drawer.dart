import 'package:flutter/material.dart';
import 'weather.dart';
import 'notam.dart';


class DrawerPage extends StatefulWidget {

 final String caller;

  const DrawerPage ({this.caller});

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: ImageIcon(AssetImage("assets/icons/drawer_wx.png")),
            title: Text('Weather'),
            onTap: () {
              Navigator.pop(context);
              if (widget.caller != "weather") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherPage()),
                );
              }
            },
          ),
          ListTile(
            leading: ImageIcon(AssetImage("assets/icons/drawer_wx.png")),
            title: Text('NOTAM'),
            onTap: () {
              Navigator.pop(context);
              if (widget.caller != "notam") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotamPage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
