import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:cavokator_flutter/json_models/wx_json.dart';
import 'package:cavokator_flutter/private.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _formKey = GlobalKey<FormState>();
  final _myTextController = new TextEditingController();

  String _userSubmitText;
  List<String> _myRequestedAirports = new List<String>();
  List<WxJson> _myWeatherList = new List<WxJson>();
  bool _apiCall = false;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(children: [
                              Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                              ImageIcon(
                                  AssetImage("assets/icons/drawer_wx.png")),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 20, 0)),
                              Expanded(
                                child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    maxLines: null,
                                    controller: _myTextController,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: InputDecoration(
                                        hintText: "Enter ICAO/IATA airports"),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return "Please enter at least one valid airport!";
                                      }
                                      else { // Try to parse some airports
                                      // Split the input to suit or needs
                                      RegExp exp = new RegExp(r"([a-z]|[A-Z]){3,4}");
                                      Iterable<Match> matches = exp.allMatches(_userSubmitText);
                                      matches.forEach((m) => _myRequestedAirports.add(m.group(0)));
                                      }
                                      if (_myRequestedAirports.isEmpty) {
                                        return "Could not identify a valid airport!";
                                      }
                                    }),
                              ),
                            ]),
                            Padding(
                              padding: EdgeInsets.all(10),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  ),
                                  RaisedButton(
                                      child: Text('Fetch WX!'),
                                      onPressed: () {
                                        _fetchButtonPressed(context);
                                      }),
                                  Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 0, 10, 0)),
                                  RaisedButton(
                                      child: Text('Clear'),
                                      onPressed: () {
                                        setState(() {
                                          _apiCall = false;
                                          _myWeatherList.clear();
                                          _myTextController.text = "";
                                        });
                                      }),
                                ]),
                          ]),
                    ),
                    _showWeatherWidget(),
                  ]),
            ),
          ),
    );
  }

  void _fetchButtonPressed(BuildContext context) {
    _myRequestedAirports.clear();

    if (_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Fetching weather, hold short!'),
        ),
      );
      setState(() {
        _apiCall = true;
      });

      _callWeatherApi().then((weatherJson) {
        setState(() {
          _apiCall = false;
          if (weatherJson != null) {
            _myWeatherList = weatherJson;
          }
        });
      }); // TODO: onError???
    }
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  @override
  void initState() {
    super.initState();

    _userSubmitText = _myTextController.text;
    _myTextController.addListener(onSubmitTextChange);
  }

  // Ensure that submitted airports are split correctly
  void onSubmitTextChange() {
    String textEntered = _myTextController.text;
    // Don't do anything if we are deleting text!
    if (textEntered.length > _userSubmitText.length) {
      if (textEntered.length > 3) {
        // Take a look at the last 4 chars entered
        String lastFourChars =
            textEntered.substring(textEntered.length - 4, textEntered.length);
        // If there is at least a space, do nothing
        bool spaceDetected = true;
        for (String char in lastFourChars.split("")) {
          if (char == " ") {
            spaceDetected = false;
          }
        }
        if (spaceDetected) {
          _myTextController.text = textEntered + " ";
          _myTextController.selection = TextSelection.fromPosition(
              TextPosition(offset: _myTextController.text.length));
        }
      }
    }
    _userSubmitText = textEntered;
  }

  Future<List<WxJson>> _callWeatherApi() async {
    String allAirports = "";
    if (_myRequestedAirports.isNotEmpty) {
      for (var a in _myRequestedAirports) {
        allAirports += a;
      }
    }

    String server = PrivateVariables.apiURL;
    String api = "Wx/GetWx?";
    String source = "source=Cavokator";
    String airports = "&airports=$allAirports";
    String url = server + api + source + airports;

    List<WxJson> exportedJson;
    try {
      final response = await http.post(url).timeout(Duration(seconds: 10));
      if (response.statusCode != 200) {
        return null;
      }
      exportedJson = wxJsonFromJson(response.body);
    } catch (Exception) {
      return null;
    }
    return exportedJson;
  }

  Widget _showWeatherWidget() {
    if (_apiCall) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsetsDirectional.only(top: 50),
              child: CircularProgressIndicator(),
            ),
          ]);
    } else {
      if (_myWeatherList.isNotEmpty) {
        return Container(
          padding: EdgeInsetsDirectional.only(top: 50),
          child: Text(_myWeatherList[0].metars[0].metar),
        );
      } else {
        return Container(
            // Empty
            );
      }
    }
  }
}
