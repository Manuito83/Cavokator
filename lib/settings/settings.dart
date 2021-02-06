import 'package:cavokator_flutter/utils/theme_me.dart';
import 'package:flutter/material.dart';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'dart:async';
import 'package:cavokator_flutter/utils/shared_prefs.dart';

class SettingsPage extends StatefulWidget {
  final bool isThemeDark;
  final Widget myFloat;
  final Function callback;
  final bool showHeaders;
  final bool maxAirports;

  SettingsPage({@required this.isThemeDark, @required this.myFloat,
                @required this.callback, @required this.showHeaders,
                @required this.maxAirports});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String _openSectionValue = "0";
  bool _showHeaderSwitchPosition;
  bool _numberOfMaxAirports;


  @override
  void initState() {
    super.initState();
    _showHeaderSwitchPosition = widget.showHeaders;
    _numberOfMaxAirports = widget.maxAirports;
    _restoreSharedPreferences();

    // Delayed callback for FAB
    Future.delayed(Duration.zero, () => fabCallback());
  }


  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: CustomScrollView(
            slivers: _buildSlivers(context),
          ),
        );
      },
    );
  }

  Future<void> fabCallback() async {
    widget.callback(SizedBox.shrink());
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = new List<Widget>();

    slivers.add(_myAppBar());
    slivers.add(_settings());

    return slivers;
  }

  Widget _myAppBar() {
    return SliverAppBar(
      title: Text("Cavokator Settings"),
      pinned: true,
    );
  }

  Widget _settings () {
    return CustomSliverSection(
      child: Container (
        child: Column (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding (
              padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text (
                      "On launch: ",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                  ),
                  Flexible(
                    child: _openSectionDropdown(),
                  ),

                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text("Show header images"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                  ),
                  Flexible(
                    child: Switch(
                      value: _showHeaderSwitchPosition,
                      onChanged: (bool value) {
                        _handleThemeChanged(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text("Limit maximum number of airports requested to 8"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                  ),
                  Flexible(
                    child: Switch(
                      value: _numberOfMaxAirports,
                      onChanged: (bool value) {
                        _handleNumberOfMaxAirportsChanged(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownButton _openSectionDropdown() {
    return DropdownButton<String> (
      value: _openSectionValue,
      items: [
        DropdownMenuItem(
          value: "99",
          child: Text(
            "Open last section",
            style: TextStyle (
              fontSize: 14,
            ),
          ),
        ),
        DropdownMenuItem(
          value: "0",
          child: Text(
            "Open Weather",
            style: TextStyle (
              fontSize: 14,
            ),
          ),
        ),
        /*
        DropdownMenuItem(
          value: "1",
          child: Text(
            "Open NOTAM",
            style: TextStyle (
              fontSize: 14,
            ),
          ),
        ),
        */
        DropdownMenuItem(
          value: "1",
          child: Text(
            "Open RWY Condition",
            style: TextStyle (
              fontSize: 14,
            ),
          ),
        ),
        DropdownMenuItem(
          value: "2",
          child: Text(
            "Open TEMP Corrections",
            style: TextStyle (
              fontSize: 14,
            ),
          ),
        ),
      ],
      onChanged: (value) {
        SharedPreferencesModel().setSettingsOpenSpecificSection(value);
        setState(() {
          _openSectionValue = value;
        });
      },
    );
  }

  _handleThemeChanged(bool newValue) {
    setState(() {
      _showHeaderSwitchPosition = newValue;
    });

    SharedPreferencesModel().setSettingsShowHeaders(newValue);
  }

  _handleNumberOfMaxAirportsChanged(bool newValue) {
    setState(() {
      _numberOfMaxAirports = newValue;
    });
    if (newValue == true) {
      SharedPreferencesModel().setSettingsMaxAirports(8);
    } else {
      SharedPreferencesModel().setSettingsMaxAirports(20);
      _maxAirportDialog();
    }

  }

  Future<void> _maxAirportDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            content: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    top: 42,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  margin: EdgeInsets.only(top: 22),
                  decoration: new BoxDecoration(
                    color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // To make the card compact
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Text(
                            "Requesting more than 8 airports in the WX or NOTAM "
                                "sections could lead to application freezing, "
                                "waiting times being too high or mobile device "
                                "performance decreasing exponentially. \n\n"
                                "Regardless of this setting, be careful if "
                                "requesting too many airports!\n\n"
                                "Absolute maximum is 20.",
                          )
                      ),
                      SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Alright"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                    child: CircleAvatar(
                      backgroundColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                      radius: 22,
                      child: Icon(
                        Icons.warning,
                        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  void _restoreSharedPreferences() async {
    await SharedPreferencesModel().getSettingsOpenSpecificSection().then((onValue) {
      setState(() {
        _openSectionValue = onValue;
      });
    });

  }

}