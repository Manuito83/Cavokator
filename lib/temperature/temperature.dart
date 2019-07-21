import 'package:cavokator_flutter/temperature/temp_repeater.dart';
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
  final _myTemperatureTextController = new TextEditingController();
  final changeNotifier = new StreamController.broadcast();


  @override
  void initState() {
    super.initState();
    _restoreSharedPreferences();

    // TODO: ACTIVATE THIS!
    // SharedPreferencesModel().setSettingsLastUsedSection("2");

    // Delayed callback for FAB
    Future.delayed(Duration.zero, () => fabCallback());

    _myTemperatureTextController.addListener(_onTemperatureInputTextChange);
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

  @override
  void dispose() {
    changeNotifier.close();
    super.dispose();
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
                      // TODO: ADD CONTROLLER
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
                          // TODO: UPDATE VALUE HERE
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
                      autovalidate: true,
                      maxLines: 1,
                      controller: _myTemperatureTextController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "";
                        } else {
                          int myTemperature = int.tryParse(value);
                          if (myTemperature == null) {
                            return "Error";
                          }
                          if (myTemperature < -80 || myTemperature > 60) {
                            return "Error";
                          }
                        }
                        _temperatureInput = int.parse(value);
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

          _altitudeRepeater.length > 0
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
    Widget repeaterWidget = TempRepeaterWidget(
        temperature: _temperatureInput,
        parentValueChange: changeNotifier.stream,
    );
    setState(() {
      _altitudeRepeater.add(repeaterWidget);
    });
  }

  void _removeRepeater() {
    if (_altitudeRepeater.length > 0) {
      setState(() {
        _altitudeRepeater.removeLast();
      });
    }
  }

  void _onTemperatureInputTextChange() {
    // TODO: ADD HERE SAME CONDITIONS AS IN VALIDATOR!
    changeNotifier.sink.add(int.parse(_myTemperatureTextController.text));
  }

  void _restoreSharedPreferences() {
    // TODO
  }

}