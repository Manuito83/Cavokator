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

  int _temperatureInput;

  final _formKey = GlobalKey<FormState>();

  List<Widget> _altitudeRepeater = List<Widget>();





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
          children: <Widget>[

            _topOptions(),

            Column(
              children: _altitudeRepeater,
            ),

            _bottomButtons(),

          ],
        ),
      ),
    );
  }

  Widget _topOptions () {
    return Column(
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
                      autovalidate: true,
                      initialValue: "0",
                      validator: (value) {
                        if (value.isEmpty) {
                          return "";
                        } else {
                          int myAltitude = int.tryParse(value);
                          if (myAltitude == null) {
                            return "Error";
                          }
                          if (myAltitude < -2000 || myAltitude > 40000) {
                            return "Error";
                          }
                          _temperatureInput = myAltitude;
                          return null;
                        }
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
    );
  }

  Widget _bottomButtons () {
    return Padding(
      padding: EdgeInsets.only(top: 30, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton (
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.blue,
            child: Icon(Icons.add),
            onPressed: () {
              _addRepeater();
            },
          ),

          _altitudeRepeater.length > 1
              ? RawMaterialButton (
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.red,
                  child: Icon(Icons.remove),
                  onPressed: () {
                    _removeRepeater();
                  },
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  _addRepeater() {
    // TODO: probably need to convert this in StateFull??
    int myValue = 6;
    Widget repeaterWidget = Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("Altitude",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
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
                    autovalidate: true,
                    initialValue: myValue.toString(),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "";
                      } else {
                        int myAltitude = int.tryParse(value);
                        if (myAltitude == null) {
                          return "Error";
                        }
                        if (myAltitude < -2000 || myAltitude > 40000) {
                          return "Error";
                        }
                        myValue = int.tryParse(value);
                        return null;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Corrected",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Text(
                  (myValue * _temperatureInput).toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );

    setState(() {
      _altitudeRepeater.add(repeaterWidget);
    });
  }

  void _removeRepeater() {
    if (_altitudeRepeater.length > 1) {
      setState(() {
        _altitudeRepeater.removeLast();
      });
    }
  }

  void _restoreSharedPreferences() {
    // TODO
  }

}