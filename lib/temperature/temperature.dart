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

  bool _currentError = false;
  int _elevationInput;
  int _temperatureInput;
  List<Widget> _altitudeRepeater = List<Widget>();
  List<String> _repeaterValueList = List<String>();
  final _myElevationTextController = new TextEditingController();
  final _myTemperatureTextController = new TextEditingController();
  final elevationChangeNotifier = new StreamController.broadcast();
  final temperatureChangeNotifier = new StreamController.broadcast();
  final errorChangeNotifier = new StreamController.broadcast();


  @override
  void initState() {
    super.initState();
    _restoreSharedPreferences();

    _myElevationTextController.text = "0";
    _myTemperatureTextController.text = "0";

    // TODO: ACTIVATE THIS!
    // SharedPreferencesModel().setSettingsLastUsedSection("3");

    // Delayed callback for FAB
    Future.delayed(Duration.zero, () => fabCallback());

    _myElevationTextController.addListener(_onElevationInputTextChange);
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
    errorChangeNotifier.close();
    elevationChangeNotifier.close();
    temperatureChangeNotifier.close();
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
        "Temp. Corrections",
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
                      controller: _myElevationTextController,
                      autovalidate: true,
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
                        }
                        _elevationInput = int.parse(value);
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

          _altitudeRepeater.length < 20
            ? RawMaterialButton (
                shape: new CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.blue,
                child: Icon(Icons.add),
                onPressed: () {
                  _addNewRepeater();
                },
            )
            : SizedBox.shrink(),

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

          _altitudeRepeater.length > 1
            ? RawMaterialButton (
                shape: new CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.yellow,
                child: Icon(Icons.delete),
                onPressed: () {
                  _clearAll();
                },
            )
            : SizedBox.shrink(),

        ],
      ),
    );
  }

  _addNewRepeater() {

    _repeaterValueList.add("");

    Widget repeaterWidget = TempRepeaterWidget(
      currentError: _currentError,
      elevation: _elevationInput,
      temperature: _temperatureInput,
      elevationParentValueChange: elevationChangeNotifier.stream,
      temperatureParentValueChange: temperatureChangeNotifier.stream,
      errorParentValueChange: errorChangeNotifier.stream,
      repeaterId: _repeaterValueList.length - 1,
      callbackValue: _repeaterWasUpdated,
      // presetValue: // TODO: delete this, it's here just to remember this option when using the list
    );

    setState(() {
      _altitudeRepeater.add(repeaterWidget);
    });

    if (_altitudeRepeater.length == 20) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Reached limit of corrections (20)!"),
        ),
      );
    }
  }

  void _removeRepeater() {
    if (_altitudeRepeater.length > 0) {
      setState(() {
        _altitudeRepeater.removeLast();
      });
      _repeaterValueList.removeLast();
      SharedPreferencesModel().setTemperatureValueList(_repeaterValueList);
    }
  }

  void _clearAll() {
    if (_altitudeRepeater.length > 1) {
      setState(() {
        _altitudeRepeater.clear();
      });
      _repeaterValueList.clear();
      SharedPreferencesModel().setTemperatureValueList(_repeaterValueList);
    }
  }

  void _repeaterWasUpdated (int repeaterId, int newValue) {  // TODO: IMPLEMENT
    _repeaterValueList[repeaterId] = newValue.toString();
    SharedPreferencesModel().setTemperatureValueList(_repeaterValueList);
  }

  void _onElevationInputTextChange() {
    int myAltitude = int.tryParse(_myElevationTextController.text);
    if (_myElevationTextController.text.isEmpty
        || myAltitude == null
        || myAltitude < -2000 || myAltitude > 40000) {
      _currentError = true;
      errorChangeNotifier.sink.add(1);
    } else {
      _currentError = false;
      errorChangeNotifier.sink.add(0);
      elevationChangeNotifier.sink.add(int.parse(_myElevationTextController.text));
    }
  }

  void _onTemperatureInputTextChange() {
    int myTemperature = int.tryParse(_myTemperatureTextController.text);
    if (_myTemperatureTextController.text.isEmpty
        || myTemperature == null
        || myTemperature < -80 || myTemperature > 60) {
      _currentError = true;
      errorChangeNotifier.sink.add(1);
    } else {
      _currentError = false;
      errorChangeNotifier.sink.add(0);
      temperatureChangeNotifier.sink.add(int.parse(_myTemperatureTextController.text));
    }
  }

  void _restoreSharedPreferences() {  // TODO: IMPLEMENT!

    // TODO: elevation and temperature


    SharedPreferencesModel().getTemperatureValueList().then((onValue) {
      if (onValue.isNotEmpty) {
        _repeaterValueList = onValue;
        for (var i = 0; i < _repeaterValueList.length; ++i) {
          Widget repeaterWidget = TempRepeaterWidget(
            currentError: _currentError,
            elevation: _elevationInput,
            temperature: _temperatureInput,
            elevationParentValueChange: elevationChangeNotifier.stream,
            temperatureParentValueChange: temperatureChangeNotifier.stream,
            errorParentValueChange: errorChangeNotifier.stream,
            repeaterId: _repeaterValueList.length - 1,
            callbackValue: _repeaterWasUpdated,
            presetValue: _repeaterValueList[i].toString(),
          );
          setState(() {
            _altitudeRepeater.add(repeaterWidget);
          });
        }
      }
    });
  }

}