import 'package:flutter/material.dart';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'dart:async';
import 'package:cavokator_flutter/utils/shared_prefs.dart';

class SettingsPage extends StatefulWidget {
  final bool isThemeDark;
  final Widget myFloat;
  final Function callback;
  final bool showHeaders;

  SettingsPage({@required this.isThemeDark, @required this.myFloat,
                @required this.callback, @required this.showHeaders});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String _openSectionValue = "0";
  bool showHeaderSwitchPosition;


  @override
  void initState() {
    super.initState();
    showHeaderSwitchPosition = widget.showHeaders;
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
                  Flexible(
                    child: Text("Show header images"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                  ),
                  Flexible(
                    child: Switch(
                      value: showHeaderSwitchPosition,
                      onChanged: (bool value) {
                        _handleThemeChanged(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
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
        DropdownMenuItem(
          value: "1",
          child: Text(
            "Open NOTAM",
            style: TextStyle (
              fontSize: 14,
            ),
          ),
        ),
        DropdownMenuItem(
          value: "2",
          child: Text(
            "Open RWY Condition",
            style: TextStyle (
              fontSize: 14,
            ),
          ),
        ),
        // TODO: ADD LOW TEMPERATURE!
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
      showHeaderSwitchPosition = newValue;
    });

    SharedPreferencesModel().setSettingsShowHeaders(newValue);
  }


  void _restoreSharedPreferences() async {
    await SharedPreferencesModel().getSettingsOpenSpecificSection().then((onValue) {
      setState(() {
        _openSectionValue = onValue;
      });
    });

  }

}