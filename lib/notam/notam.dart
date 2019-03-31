import 'package:flutter/material.dart';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'package:cavokator_flutter/json_models/wx_json.dart'; // TODO: cambiar por NOTAMJson
import 'package:cavokator_flutter/utils/theme_me.dart';

class NotamPage extends StatefulWidget {

  NotamPage({@required this.isThemeDark});

  final bool isThemeDark;

  @override
  _NotamPageState createState() => _NotamPageState();
}

class _NotamPageState extends State<NotamPage> {
  final _formKey = GlobalKey<FormState>();
  final _myTextController = new TextEditingController();

  String _userSubmitText;
  List<String> _myRequestedAirports = new List<String>();
  List<WxJson> _myWeatherList = new List<WxJson>();
  bool _apiCall = false;

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

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = new List<Widget>();

    slivers.add(_myAppBar());
    slivers.add(_inputForm());

    /*
    var wxSect = _weatherSections();
    for (var section in wxSect) {
      slivers.add(section);
    }
    */

    return slivers;
  }

  Widget _myAppBar() {
    return SliverAppBar(
      iconTheme: new IconThemeData(color: Colors.black),
      title: Text(
        "Weather",
        style: TextStyle(color: Colors.black),
      ),
      expandedHeight: 150,
      // TODO: Settings option (value '0' if inactive)
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/weather_header.jpg'),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.access_alarm),
          color: Colors.black,
          onPressed: () {
            // TEST
          },
        ),
        IconButton(
          icon: Icon(Icons.clear),
          color: Colors.black,
          onPressed: () {
            // TEST
          },
        ),
      ],
    );
  }

  Widget _inputForm() {
    return CustomSliverSection(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 50),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            border: Border.all(color: Colors.grey),
            color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      ),
                      ImageIcon(
                        AssetImage("assets/icons/drawer_wx.png"),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      ),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          controller: _myTextController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: "Enter ICAO/IATA airports",
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please enter at least one valid airport!";
                            } else {
                              // Try to parse some airports
                              // Split the input to suit or needs
                              RegExp exp = new RegExp(r"([a-z]|[A-Z]){3,4}");
                              Iterable<Match> matches =
                              exp.allMatches(_userSubmitText);
                              matches.forEach(
                                      (m) => _myRequestedAirports.add(m.group(0)));
                            }
                            if (_myRequestedAirports.isEmpty) {
                              return "Could not identify a valid airport!";
                            }
                          },
                        ),
                      ),
                    ],
                  ),
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
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                      RaisedButton(
                        child: Text('Clear'),
                        onPressed: () {
                          setState(() {
                            _apiCall = false;
                            _myWeatherList.clear();
                            //SharedPreferencesModel().setWeatherUserInput("");
                            //SharedPreferencesModel().setWeatherInformation("");
                            _myTextController.text = "";
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    //super.initState();

    //_myCurrentSubmitText = _myTextController.text;
    //_myTextController.addListener(onSubmitTextChange);
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
      /*
      _callWeatherApi().then((weatherJson) {
        setState(() {
          _apiCall = false;
          if (weatherJson != null) {
            _myWeatherList = weatherJson;
          }
        });
      });
      */
    }
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  // Ensure that submitted airports are split correctly
  void onInputTextChange() {
    // Ensure that submitted airports are split correctly
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

}