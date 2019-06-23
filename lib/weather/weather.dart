import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:cavokator_flutter/json_models/wx_json.dart';
import 'package:cavokator_flutter/private.dart';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'package:cavokator_flutter/weather/wx_item_builder.dart';
import 'package:cavokator_flutter/utils/pretty_duration.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';
import 'package:cavokator_flutter/weather/wx_colorize.dart';
import 'package:cavokator_flutter/weather/wx_split_tafor.dart';
import 'package:cavokator_flutter/utils/theme_me.dart';
//import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class WeatherPage extends StatefulWidget {

  WeatherPage({@required this.isThemeDark, @required this.myFloat, @required this.callback});

  final bool isThemeDark;
  final Widget myFloat;
  final Function callback;

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _formKey = GlobalKey<FormState>();
  final _myTextController = new TextEditingController();

  Timer _ticker;

  bool _splitTafor = true;

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

    var wxSect = _weatherSections();
    for (var section in wxSect) {
      slivers.add(section);
    }

    return slivers;
  }

  Widget _myAppBar() {
    return SliverAppBar(
      iconTheme: IconThemeData(color: Colors.black),
      title: Text(
          "Weather",
        style: TextStyle(color: Colors.black),
      ),
      expandedHeight: 150,
      // TODO: Settings option (value '0' if inactive)
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/weather_header.jpg'),
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
          //color: Colors.grey[200],
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
                            SharedPreferencesModel().setWeatherUserInput("");
                            SharedPreferencesModel().setWeatherInformation("");
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

  List<Widget> _weatherSections() {
    List<Widget> mySections = List<Widget>();

    if (_apiCall) {
      mySections.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsetsDirectional.only(top: 50),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
            childCount: 1,
          ),
        ),
      );
    } else {
      if (_myWeatherList.isNotEmpty) {
        var wxBuilder = WxItemBuilder(jsonWeatherList: _myWeatherList);
        var wxModel = wxBuilder.result;

        for (var i = 0; i < wxModel.wxModelList.length; i++) {
          mySections.add(
            SliverStickyHeaderBuilder(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Container(
                    margin: EdgeInsetsDirectional.only(bottom: 25),
                    height: 60.0,
                    color: (state.isPinned ? Colors.red[300] : Colors.lightBlue)
                        .withOpacity(1.0 - state.scrollPercentage),
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.local_airport, color: Colors.white),
                        Padding(
                          padding: EdgeInsetsDirectional.only(end: 15),
                        ),
                        Flexible(
                          child: Text(
                            wxModel.wxModelList[i].airportHeading,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {

                    // TODO: errors need to be implemented! (ej: LECS/CUAC)

                    final item = wxModel.wxModelList[i].airportWeather[index];

                    if (item is AirportMetar || item is AirportTafor){
                      TextSpan wxSpan;
                      Widget myWeatherLineWidget;
                      if (item is AirportMetar){

                        // DEBUG
                        item.metars[0] = "LEZL 162030Z CAVOK 15/10 R27L/356691 "
                            "lala 88356691 LALA R/SNOCLO LALA R27/CLRD// LALA";

                        wxSpan = MetarColorize(metar: item.metars[0], context: context).getResult;
                        myWeatherLineWidget = RichText(text: wxSpan);
                      } else if (item is AirportTafor){
                        var myTaforString = item.tafors[0];
                        List<Widget> myWeatherRows = List<Widget>();
                        if (_splitTafor){
                          List<String> splitList = SplitTafor(taforString: myTaforString).getResult;
                          for (var split in splitList){
                            List<TextSpan> thisSpan = List<TextSpan>();
                            if (split.contains("[/trend]")){
                              var splitAgain = split.split("[/trend]");
                              var firstSpan = TextSpan(
                                text: splitAgain[0],
                                style: TextStyle(color: Colors.blue),
                              );
                              var secondSpan = MetarColorize(metar: splitAgain[1], context: context).getResult;
                              thisSpan.add(firstSpan);
                              thisSpan.add(secondSpan);
                              myWeatherRows.add(
                                Container(
                                  padding: EdgeInsets.only(left: 8, top: 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.play_arrow, color: Colors.blue, size: 16,),
                                      Padding(padding: EdgeInsets.only(left: 2)),
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                              children: thisSpan
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              List<TextSpan> thisSpan = List<TextSpan>();
                              thisSpan.add(MetarColorize(metar: split, context: context).getResult);
                              myWeatherRows.add(
                                Row(
                                  children: [
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          children: thisSpan,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            myWeatherLineWidget = Column(
                              children: myWeatherRows,
                            );

                          }
                        }
                        else {
                          // TODO: is this OK?
                          wxSpan = MetarColorize(metar: myTaforString, context: context).getResult;
                          myWeatherLineWidget = RichText(text: wxSpan);
                        }
                      }
                      return ListTile(
                        title: Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                            child: myWeatherLineWidget,
                          ),
                        ),
                      );
                    }

                    if (item is MetarTimes){
                      PrettyTimeCombination metarTimeFinal;
                      Color clockIconColor;
                      if (!item.error) {
                        try {

                          // TODO: what if time null in API??
                          var myPrettyDuration = PrettyDuration(
                            referenceTime: item.metarTimes[0],
                            header: "METAR",
                            prettyType: PrettyType.metar
                          );
                          metarTimeFinal = myPrettyDuration.getDuration;
                          clockIconColor = metarTimeFinal.prettyColor;

                        } catch (Exception) {
                          // TODO error
                          clockIconColor = Colors.red;
                        }
                      } else {
                        // TODO error
                        clockIconColor = Colors.red;
                      }
                      return ListTile(
                        title: Container(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.access_time,
                                color: clockIconColor,
                              ),
                              Padding(padding: EdgeInsets.only(right: 15)),
                              Flexible(
                                child: Text(metarTimeFinal.prettyDuration,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: metarTimeFinal.prettyColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (item is TaforTimes){
                      PrettyTimeCombination taforTimeFinal;
                      Color clockIconColor;
                      if (!item.error) {
                        try {
                          // TODO: what if time null in API??
                          var myPrettyDuration = PrettyDuration(
                              referenceTime: item.taforTimes[0],
                              header: "TAFOR",
                              prettyType: PrettyType.tafor
                          );
                          taforTimeFinal = myPrettyDuration.getDuration;
                          clockIconColor = taforTimeFinal.prettyColor;

                        } catch (Exception) {
                          // TODO error
                          clockIconColor = Colors.red;
                        }
                      } else {
                        // TODO error
                        clockIconColor = Colors.red;
                      }
                      return ListTile(
                        title: Container(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.access_time,
                                color: clockIconColor,
                              ),
                              Padding(padding: EdgeInsets.only(right: 15)),
                              Flexible(
                                child: Text(taforTimeFinal.prettyDuration,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: taforTimeFinal.prettyColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      /*
                      return ListTile(
                        title: Text(item.taforTimes[0].toString()),
                      );

                       */
                    }

                  },
                  childCount: wxModel.wxModelList[i].airportWeather.length,
                ),
              ),
            ),
          );
          // We need to add another sliver to give extra space
          // SliverPadding results in weird header behaviour, so we
          // use a Container with margin here
          mySections.add(
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => Container(
                  margin: EdgeInsets.only(bottom: 80),
                ),
                childCount: 1,
              ),
            ),
            //SliverPadding(padding: EdgeInsetsDirectional.only(top: 80)),
          );
        }
      } else {
        mySections.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(),
              childCount: 1,
            ),
          ),
        );
      }
    }

    return mySections;
  }

  void _updateTimes(){
    print("UPDATING WX TICKER: ${DateTime.now().toUtc()}");
    if (_myWeatherList.isNotEmpty){
          setState(() {
            // This will trigger a refresh of weather times
          });
    }
  }


  @override
  void initState() {
    super.initState();

    _restoreSharedPreferences();

    // Delayed callback for FAB
    Future.delayed(Duration.zero, () => fabCallback());

    _ticker = new Timer.periodic(Duration(seconds:30), (Timer t) => _updateTimes());

    _userSubmitText = _myTextController.text;
    _myTextController.addListener(onInputTextChange);
  }

  Future<void> fabCallback() async {
    widget.callback(SizedBox.shrink());
  }


  void _restoreSharedPreferences() {
    SharedPreferencesModel().getWeatherUserInput().then((onValue) {
      setState(() {
        _myTextController.text = onValue;
      });
    });

    SharedPreferencesModel().getWeatherInformation().then((onValue) {
      if (onValue.isNotEmpty){
        setState(() {
          _myWeatherList = wxJsonFromJson(onValue);
        });
      }
    });
  }

  @override
  void dispose(){
    _ticker?.cancel();
    super.dispose();
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
      });
    }
    FocusScope.of(context).requestFocus(new FocusNode());
  }

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

  Future<List<WxJson>> _callWeatherApi() async {
    String allAirports = "";
    if (_myRequestedAirports.isNotEmpty) {
      for (var i = 0; i < _myRequestedAirports.length; i++) {
        if (i != _myRequestedAirports.length - 1) {
          allAirports += _myRequestedAirports[i] + ",";
        } else {
          allAirports += _myRequestedAirports[i];
        }
      }
    }

    String server = PrivateVariables.apiURL;
    String api = "Wx/GetWx?";
    String source = "source=Cavokator";
    String airports = "&airports=$allAirports";
    String url = server + api + source + airports;

    List<WxJson> exportedJson;
    try {
      final response = await http.post(url).timeout(Duration(seconds: 60));
      if (response.statusCode != 200) {
        // TODO: this error is OK, but what about checking Internet connectivity as well??
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Oops! There was connection error!',
                style: TextStyle(
                  color: Colors.black,
                )
            ),
            backgroundColor: Colors.red[100],
          ),
        );
        return null;
      }
      exportedJson = wxJsonFromJson(response.body);
      SharedPreferencesModel().setWeatherInformation(response.body);
      SharedPreferencesModel().setWeatherUserInput(_userSubmitText);
    } catch (Exception) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Oops! There was connection error!',
            style: TextStyle(
              color: Colors.black,
            )
          ),
          backgroundColor: Colors.red[100],
        ),
      );
      return null;
    }
    return exportedJson;
  }

}
