import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:cavokator_flutter/json_models/wx_json.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _formKey = GlobalKey<FormState>();
  final _myTextController = new TextEditingController();

  String _myCurrentSubmitText;

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
                                    }),
                              ),
                            ]),
                            Padding(
                              padding: EdgeInsets.all(10),
                            ),
                            RaisedButton(
                                child: Text('Fetch WX!'),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content: Text('Processing Data')));
                                    _getWeatherInformation();
                                    setState(() {});
                                  }
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                }),
                          ]),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                      child: FutureBuilder<List<WxJson>>(
                          future: _getWeatherInformation(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data[0].airportIdIata);
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }
                            // By default, show a loading spinner
                            return CircularProgressIndicator();
                          }),
                    ),
                  ]),
            ),
          ),
    );
  }

  @override
  void initState() {
    super.initState();

    _myCurrentSubmitText = _myTextController.text;
    _myTextController.addListener(onSubmitTextChange);
  }

  // Ensure that submitted airports are split correctly
  void onSubmitTextChange() {
    String textEntered = _myTextController.text;
    // Don't do anything if we are deleting text!
    if (textEntered.length > _myCurrentSubmitText.length) {
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
    _myCurrentSubmitText = textEntered;
  }

  Future<List<WxJson>> _getWeatherInformation() async {
    String url = 'https://manuito.a2hosted.com/CavokatorApi_V2/Wx/GetWx?source=Cavokator&airports=LEZL';
    final response = await http.post(url);

    if (response.statusCode == 200) {
      // TODO: implement
    }

    return wxJsonFromJson(response.body);
  }
}
