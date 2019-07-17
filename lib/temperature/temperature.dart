import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cavokator_flutter/utils/theme_me.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';
import 'package:flutter/services.dart';


class TemperaturePage extends StatefulWidget {
  final bool isThemeDark;
  final Widget myFloat;
  final Function callback;
  final bool showHeaders;

  TemperaturePage({@required this.isThemeDark, @required this.myFloat,
    @required this.callback, @required this.showHeaders});

  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {

  @override
  void initState() {
    super.initState();

    _restoreSharedPreferences();

    // TODO: ACTIVATE THIS!
    // SharedPreferencesModel().setSettingsLastUsedSection("2");

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
    slivers.add(_mainBody());

    return slivers;
  }

  Widget _myAppBar() {
    return SliverAppBar(
      iconTheme: IconThemeData(
        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
      ),
      title: Text(
        "Temperature Corrections",
        style: TextStyle(
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
        ),
      ),
      expandedHeight: widget.showHeaders ? 150 : 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/temperature_header.jpg'),
              fit: BoxFit.fitWidth,
              colorFilter: widget.isThemeDark == true
                  ? ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainBody (){
    return CustomSliverSection(
      child: Container(
        padding: EdgeInsets.only(left: 30, top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row (
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text("Aerodrome Elevation (ft):",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          )
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: Column (
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 80,
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(5),
                          ],
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          keyboardType: TextInputType.numberWithOptions(),
                          maxLines: 1,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Did you forget something?";
                            } else {
                              // TODO
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
            ),
            Row (
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text("Temperature (ºC):",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          )
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: Column (
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 40,
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(3),
                          ],
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          keyboardType: TextInputType.numberWithOptions(),
                          maxLines: 1,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Did you forget something?";
                            } else {
                              // TODO
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              child: Divider(),
              padding: EdgeInsets.symmetric(vertical: 30),
            ),
          ],
        ),
      ),
    );
  }

  void _restoreSharedPreferences() {

  }

}