import 'package:cavokator_flutter/temperature/temp_repeater.dart';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'package:cavokator_flutter/utils/hyperlink.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cavokator_flutter/utils/theme_me.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';
import 'package:flutter/services.dart';
import 'package:cavokator_flutter/temperature/temp_options_dialog.dart';
import 'package:share/share.dart';


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
  List<String> _repeaterCorrectionList = List<String>();

  final _myElevationTextController = new TextEditingController();
  final _myTemperatureTextController = new TextEditingController();

  final elevationChangeNotifier = new StreamController.broadcast();
  final temperatureChangeNotifier = new StreamController.broadcast();
  final errorChangeNotifier = new StreamController.broadcast();
  final roundChangeNotifier = new StreamController.broadcast();

  bool _round = true;

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
    roundChangeNotifier.close();
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
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.playlist_add_check),
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          onPressed: () {
            return _showStandardDialog();
          },
        ),
        IconButton(
          icon: Icon(Icons.settings),
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          onPressed: () {
            return _showSettings();
          },
        ),
        IconButton(
          icon: Icon(Icons.share),
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          onPressed: () {
            Share.share(_generateShareString());
          },
        ),
        IconButton(
          icon: Icon(Icons.warning),
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          onPressed: () {
            return _warningDialog();
          },
        ),
      ],
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
                          if (myAltitude < -2000 || myAltitude > 10000) {
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
                          if (myTemperature < -50 || myTemperature > 50) {
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
                fillColor: Colors.orangeAccent[200],
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
    _repeaterCorrectionList.add("");

    Widget repeaterWidget = TempRepeaterWidget(
      key: UniqueKey(),
      currentError: _currentError,
      elevation: _elevationInput,
      temperature: _temperatureInput,
      round: _round,
      elevationParentValueChange: elevationChangeNotifier.stream,
      temperatureParentValueChange: temperatureChangeNotifier.stream,
      errorParentValueChange: errorChangeNotifier.stream,
      roundParentValueChange: roundChangeNotifier.stream,
      repeaterId: _repeaterValueList.length - 1,
      callbackValue: _repeaterValueUpdated,
      callbackCorrection: _repeaterCorrectionUpdated,
      presetValue: null,
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
      setState(() {
        _altitudeRepeater.removeLast();
      });
      _repeaterValueList.removeLast();
      _repeaterCorrectionList.removeLast();
      SharedPreferencesModel().setTemperatureValueList(_repeaterValueList);
      SharedPreferencesModel().setTemperatureCorrectionList(_repeaterCorrectionList);
  }


  void _clearAll() {
    setState(() {
      _altitudeRepeater.clear();
    });
    _repeaterValueList.clear();
    _repeaterCorrectionList.clear();
    SharedPreferencesModel().setTemperatureValueList(_repeaterValueList);
    SharedPreferencesModel().setTemperatureCorrectionList(_repeaterCorrectionList);
  }


  void _repeaterValueUpdated (int repeaterId, int newValue) {
    _repeaterValueList[repeaterId] = newValue.toString();
    SharedPreferencesModel().setTemperatureValueList(_repeaterValueList);
  }


  void _repeaterCorrectionUpdated (int repeaterId, int newCorrection) {
    _repeaterCorrectionList[repeaterId] = newCorrection.toString();
    SharedPreferencesModel().setTemperatureCorrectionList(_repeaterCorrectionList);
  }


  void _onElevationInputTextChange() {
    int inputElevation = int.tryParse(_myElevationTextController.text);
    if (_myElevationTextController.text.isEmpty
        || inputElevation == null
        || inputElevation < -2000 || inputElevation > 10000) {
      _currentError = true;
      errorChangeNotifier.sink.add(1);
      SharedPreferencesModel().setTemperatureElev(inputElevation);
    } else {
      _currentError = false;
      errorChangeNotifier.sink.add(0);
      elevationChangeNotifier.sink.add(inputElevation);
      SharedPreferencesModel().setTemperatureElev(inputElevation);
    }
  }

  void _onTemperatureInputTextChange() {
    int inputTemperature = int.tryParse(_myTemperatureTextController.text);
    if (_myTemperatureTextController.text.isEmpty
        || inputTemperature == null
        || inputTemperature < -50 || inputTemperature > 50) {
      _currentError = true;
      errorChangeNotifier.sink.add(1);
      SharedPreferencesModel().setTemperatureTemp(inputTemperature);
    } else {
      _currentError = false;
      errorChangeNotifier.sink.add(0);
      temperatureChangeNotifier.sink.add(inputTemperature);
      SharedPreferencesModel().setTemperatureTemp(inputTemperature);
    }
  }

  void _restoreSharedPreferences() async {

    await SharedPreferencesModel().getTemperatureElev().then((onValue) {
      _elevationInput = onValue;
      _myElevationTextController.text = onValue.toString();
    });

    await SharedPreferencesModel().getTemperatureTemp().then((onValue) {
      _temperatureInput = onValue;
      _myTemperatureTextController.text = onValue.toString();
    });

    await SharedPreferencesModel().getTemperatureCorrectionList().then((onValue) {
      if (onValue.isNotEmpty) {
        _repeaterCorrectionList = onValue;
      }
    });

    await SharedPreferencesModel().getTempRound().then((onValue) {
      _round = onValue;
    });

    await SharedPreferencesModel().getTemperatureValueList().then((onValue) {
      if (onValue.isNotEmpty) {
        _repeaterValueList = onValue;
        for (var i = 0; i < _repeaterValueList.length; ++i) {
          Widget repeaterWidget = TempRepeaterWidget(
            key: UniqueKey(),
            currentError: _currentError,
            elevation: _elevationInput,
            temperature: _temperatureInput,
            round: _round,
            elevationParentValueChange: elevationChangeNotifier.stream,
            temperatureParentValueChange: temperatureChangeNotifier.stream,
            errorParentValueChange: errorChangeNotifier.stream,
            roundParentValueChange: roundChangeNotifier.stream,
            repeaterId: _repeaterValueList.length - 1,
            callbackValue: _repeaterValueUpdated,
            presetValue: _repeaterValueList[i].toString(),
            callbackCorrection: _repeaterCorrectionUpdated,
          );
          setState(() {
            _altitudeRepeater.add(repeaterWidget);
          });
        }
      }
    });
  }

  Future<void> _showSettings() async {
    return showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return TempOptionsDialog(
            round: _round,
            roundChangedCallback: _roundOptionHasChanged,
          );
        }
    );
  }

  void _roundOptionHasChanged(bool newValue) {
    _round = newValue;
    roundChangeNotifier.sink.add(newValue);
  }

  String _generateShareString () {
    String shareString = "";

    shareString += "###";
    shareString += "\n### CAVOKATOR TEMP CORRECTION ###";
    shareString += "\n###";

    shareString += "\n\n# Elevation: $_elevationInput";
    shareString += "\n# Temperature: $_temperatureInput \n";

    if (_repeaterValueList.isEmpty) {
      shareString += "\nERROR: no altitudes inserted!";
    } else {
      for (var i = 0; i < _repeaterValueList.length; i++) {
        shareString += "\nAltitude: ${_repeaterValueList[i]} "
                       "is corrected to ${_repeaterCorrectionList[i]}";
      }

      if (_round) {
        shareString += "\n\nNote: Corrected altitudes are being rounded to the higher 100";
      }
    }

    shareString += "\n\n ### END CAVOKATOR REPORT ###";

    return shareString;
  }


  Future<void> _showStandardDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Generate quick list!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This will remove your current list of altitudes and '
                    'create a new one with 500 feet increments starting'
                    'from the aerodrome elevation up to 5000 AGL'
                    ''),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Do it!'),
              onPressed: () {
                Navigator.of(context).pop();
                _generateStandardList();
              },
            ),
            FlatButton(
              child: Text('Oh no!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _warningDialog() async {
    showDialog (
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "WARNING",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 30, 10, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Text("TEMPERATURE CORRECTIONS",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            "This tool is not intended to be used during "
                                "real flight operations. Please be aware that "
                                "errors in low temperature corrections might "
                                "lead to CFIT, GPWS warning or worse."
                                "\n\n"
                                "The calculations offered in CAVOKATOR are based "
                                "on ICAO Doc 8168 Vol 1, Part III, 4.3.3 "
                                '"Corrections for specific conditions", '
                                "which can be used for aerodromes above sea level "
                                "and produce results that are within 5 per cent "
                                "of the accurate correction for altimeter "
                                "setting sources up to 10 000 ft and with "
                                "minimum heights up to 5 000 ft above that source. ",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  Padding (
                    padding: EdgeInsets.fromLTRB(5, 25, 30, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible (
                          child: Text(
                            "For more information, please visit:",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding (
                    padding: EdgeInsets.fromLTRB(5, 0, 30, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible (
                          child: Hyperlink(
                              "https://www.skybrary.aero/index.php/Altimeter_Temperature_Error_Correction",
                              "Skybrary's article on Altimeter Temperature Error Correction"),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: RaisedButton(
                      child: Text(
                        "I'll be careful!",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }


  void _generateStandardList () async {

    _clearAll();

    int initialAltitude = _elevationInput + 500;
    var defaultList = List<Widget>();

    for (var i = 0; i < 10; i++) {
      _repeaterValueList.add("");
      _repeaterCorrectionList.add("");

      Widget repeaterWidget = TempRepeaterWidget(
        key: UniqueKey(),
        currentError: _currentError,
        elevation: _elevationInput,
        temperature: _temperatureInput,
        round: _round,
        elevationParentValueChange: elevationChangeNotifier.stream,
        temperatureParentValueChange: temperatureChangeNotifier.stream,
        errorParentValueChange: errorChangeNotifier.stream,
        roundParentValueChange: roundChangeNotifier.stream,
        repeaterId: _repeaterValueList.length - 1,
        callbackValue: _repeaterValueUpdated,
        presetValue: initialAltitude.toString(),
        callbackCorrection: _repeaterCorrectionUpdated,
      );

      defaultList.add(repeaterWidget);
      initialAltitude += 500;
    }

    setState(() {
      _altitudeRepeater = defaultList;
    });
  }


}