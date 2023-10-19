import 'dart:developer';

import 'package:cavokator_flutter/favourites/favourites.dart';
import 'package:cavokator_flutter/weather/wx_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:cavokator_flutter/json_models/wx_json.dart';
import 'package:cavokator_flutter/constants.dart';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'package:cavokator_flutter/weather/wx_item_builder.dart';
import 'package:cavokator_flutter/utils/pretty_duration.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';
import 'package:cavokator_flutter/weather/wx_colorize.dart';
import 'package:cavokator_flutter/weather/wx_split_tafor.dart';
import 'package:cavokator_flutter/utils/theme_me.dart';
import 'package:connectivity/connectivity.dart';
import 'package:share/share.dart';
import 'package:xml/xml.dart';
import 'dart:io';

class WeatherPage extends StatefulWidget {
  final bool? isThemeDark;
  final Widget myFloat;
  final Function callback;
  final bool showHeaders;
  final Function hideBottomNavBar;
  final Function showBottomNavBar;
  final double recalledScrollPosition;
  final Function notifyScrollPosition;
  final List<String> airportsFromFav;
  final bool autoFetch;
  final Function cancelAutoFetch;
  final Function callbackToFav;
  final bool fetchBoth;
  final int maxAirportsRequested;
  final String thisAppVersion;
  final List<List<dynamic>> airports;

  WeatherPage(
      {required this.isThemeDark,
      required this.myFloat,
      required this.callback,
      required this.showHeaders,
      required this.hideBottomNavBar,
      required this.showBottomNavBar,
      required this.recalledScrollPosition,
      required this.notifyScrollPosition,
      required this.autoFetch,
      required this.cancelAutoFetch,
      required this.callbackToFav,
      required this.airportsFromFav,
      required this.fetchBoth,
      required this.maxAirportsRequested,
      required this.thisAppVersion,
      required this.airports});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _formKey = GlobalKey<FormState>();
  final _myTextController = TextEditingController();

  final _myMainScrollController = ScrollController();

  Timer? _ticker;

  bool _splitTafor = true;

  late String _userSubmitText;
  List<String> _myRequestedAirports = [];
  List<WxJson> _myWeatherList = [];
  bool _apiCall = false;

  String _mySharedWeather = "";

  int _hoursBefore = 10;
  bool _mostRecent = true;

  bool _autoFetch = false;
  bool _fetchBoth = false;
  int _airportsFromFav = 0;

  @override
  void initState() {
    super.initState();
    _fetchBoth = widget.fetchBoth;
    _autoFetch = widget.autoFetch;
    // If we get all, both request will interfere,
    // so we just get the basics
    if (_autoFetch) {
      _restoreHoursBefore();
    } else {
      _restoreSharedPreferences();
    }
    SharedPreferencesModel().setSettingsLastUsedSection("0");

    // Delayed callback for FAB
    Future.delayed(Duration.zero, () => fabCallback());

    _ticker = Timer.periodic(Duration(seconds: 30), (Timer t) => _updateTimes());

    _userSubmitText = _myTextController.text;
    _myTextController.addListener(onInputTextChange);

    _myMainScrollController.addListener(onMainScrolled);

    // TODO (maybe?): setting to deactivate this?
    Future.delayed(Duration(milliseconds: 500), () {
      _myMainScrollController.animateTo(
        widget.recalledScrollPosition,
        duration: Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
      );
    });

    if (widget.airportsFromFav.length > 0) {
      _airportsFromFav = widget.airportsFromFav.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 500), () {
          // If joining with commas in the future, make sure that
          // all sections work as expected (Lists are correctly in sharedPrefs)
          _myTextController.text = widget.airportsFromFav.join(" ");
          if (_autoFetch) {
            _fetchButtonPressed(context, _fetchBoth);
          }
          widget.cancelAutoFetch();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: CustomScrollView(
            controller: _myMainScrollController,
            slivers: _buildSlivers(context),
          ),
        );
      },
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = <Widget>[];

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
      iconTheme: IconThemeData(
        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
      ),
      title: Text(
        "Weather",
        style: TextStyle(
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
        ),
      ),
      expandedHeight: widget.showHeaders ? 150 : 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/weather_header.jpg'),
              fit: BoxFit.fitWidth,
              colorFilter:
                  widget.isThemeDark == true ? ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken) : null,
            ),
          ),
        ),
      ),
      actions: <Widget>[
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
            if (_mySharedWeather != "") {
              Share.share(_mySharedWeather);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Nothing to share!',
                  ),
                ),
              );
            }
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
                        child: ImageIcon(
                          AssetImage("assets/icons/drawer_wx.png"),
                          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 14,
                          ),
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          controller: _myTextController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            errorMaxLines: 3,
                            labelText: "Enter ICAO/IATA airports",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter at least one valid airport!";
                            } else {
                              // Try to parse some airports
                              // Split the input to suit or needs
                              RegExp exp = RegExp(r"([a-z]|[A-Z]){3,4}");
                              Iterable<Match> matches = exp.allMatches(_userSubmitText);
                              matches.forEach((m) {
                                if (m.group(0) != null) {
                                  _myRequestedAirports.add(m.group(0)!);
                                }
                              });
                            }
                            if (_myRequestedAirports.isEmpty) {
                              return "Could not identify a valid airport!";
                            }
                            if (_myRequestedAirports.length > widget.maxAirportsRequested) {
                              return "Too many airports (max is ${widget.maxAirportsRequested})! "
                                  "You can change this in settings.";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: ButtonTheme(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minWidth: 1.0,
                          buttonColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.Buttons),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: BorderSide(
                                    color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText)!,
                                  ),
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              var favAirports = <String>[];
                              RegExp exp = RegExp(r"([a-z]|[A-Z]){3,4}");
                              Iterable<Match> matches = exp.allMatches(_myTextController.text);
                              matches.forEach((m) {
                                if (m.group(0) != null) {
                                  favAirports.add(m.group(0)!);
                                }
                              });
                              widget.callbackToFav(3, FavFrom.weather, favAirports);
                            },
                          ),
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
                      ButtonTheme(
                        minWidth: 1.0,
                        buttonColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.Buttons),
                        child: ElevatedButton(
                          child: ImageIcon(AssetImage("assets/icons/drawer_wx.png"), color: Colors.white),
                          onPressed: () {
                            _fetchButtonPressed(context, false);
                          },
                        ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                      /*
                      ButtonTheme(
                        minWidth: 1.0,
                        buttonColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.Buttons),
                        child: ElevatedButton(
                          child: Row(
                            children: <Widget>[
                              ImageIcon(
                                AssetImage("assets/icons/drawer_wx.png"),
                                color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                              ),
                              Text(" + "),
                              ImageIcon(
                                AssetImage("assets/icons/drawer_notam.png"),
                                color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                              ),
                            ],
                          ),
                          onPressed: ()  {
                            _fetchButtonPressed(context, true);
                          },
                        ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                      */
                      ButtonTheme(
                        minWidth: 1.0,
                        buttonColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                        child: ElevatedButton(
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _apiCall = false;
                              _myWeatherList.clear();
                              SharedPreferencesModel().setWeatherUserInput("");
                              SharedPreferencesModel().setWeatherInformation("");
                              _myTextController.text = "";
                              _mySharedWeather = "";
                            });
                          },
                        ),
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
    List<Widget> mySections = <Widget>[];

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

        _mySharedWeather = "";
        _mySharedWeather += "###";
        _mySharedWeather += "\n### CAVOKATOR WEATHER ###";
        _mySharedWeather += "\n###";

        for (var i = 0; i < wxModel.wxModelList.length; i++) {
          var airportName = wxModel.wxModelList[i].airportHeading == null
              ? _myRequestedAirports[i].toUpperCase()
              : wxModel.wxModelList[i].airportHeading;

          _mySharedWeather += "\n\n\n### $airportName ###";
          if (!wxModel.wxModelList[i].airportFound) {
            _mySharedWeather += "\n\nERROR: AIRPORT NOT FOUND!";
          }
          if (wxModel.wxModelList[i].airportWeather.length == 0) {
            _mySharedWeather += "\n\nNo weather information found in this airport!";
          }
          for (var b = 0; b < wxModel.wxModelList[i].airportWeather.length; b++) {
            var thisItem = wxModel.wxModelList[i].airportWeather[b];

            if (thisItem is AirportMetar) {
              for (var met in thisItem.metars) {
                _mySharedWeather += "\n\n## METAR \n$met";
              }
            } else if (thisItem is AirportTafor) {
              for (var taf in thisItem.tafors) {
                _mySharedWeather += "\n\n## TAFOR \n$taf";
              }
            }
          }
          if (i == wxModel.wxModelList.length - 1) {
            _mySharedWeather += "\n\n\n\n ### END CAVOKATOR REPORT ###";
          }

          mySections.add(
            SliverStickyHeaderBuilder(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Container(
                    margin: EdgeInsetsDirectional.only(bottom: 25),
                    height: 60.0,
                    color: (state.isPinned
                        ? ThemeMe.apply(widget.isThemeDark, DesiredColor.HeaderPinned)
                        : ThemeMe.apply(widget.isThemeDark, DesiredColor.HeaderUnpinned)!
                            .withOpacity(1.0 - state.scrollPercentage)),
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
                            "(${_myRequestedAirports[i].toUpperCase()}) " + airportName!,
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
                    if (!wxModel.wxModelList[i].airportFound) {
                      return ListTile(
                        title: Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                            child: RichText(
                              text: TextSpan(
                                text: "Airport not found!",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      final item = wxModel.wxModelList[i].airportWeather[index];

                      if (item is AirportMetar) {
                        // DEBUG METAR HERE (not times)
                        //item.metars[0] = "LEZL 162030Z CAVOK "
                        //"R25R/123456 2000 0800 R23/M2000U";

                        var metarLines = <Widget>[];
                        for (var m = 0; m < item.metars.length; m++) {
                          var wxSpan =
                              MetarColorize(metar: item.metars[m]!, isThemeDark: widget.isThemeDark, context: context)
                                  .getResult;

                          var myText = RichText(text: wxSpan);

                          metarLines.add(myText);

                          if (m < item.metars.length - 1) {
                            metarLines.add(Padding(
                              padding: EdgeInsets.only(bottom: 20),
                            ));
                          }
                        }

                        return ListTile(
                          title: Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: metarLines,
                              ),
                            ),
                          ),
                        );
                      }

                      if (item is AirportTafor) {
                        TextSpan? wxSpan;
                        var myWeatherLineWidget;

                        var myTaforString = item.tafors[0];
                        List<Widget> myWeatherRows = <Widget>[];
                        if (_splitTafor) {
                          List<String> splitList = SplitTafor(taforString: myTaforString).getResult;
                          for (var split in splitList) {
                            List<TextSpan> thisSpan = <TextSpan>[];
                            if (split.contains("[/trend]")) {
                              var splitAgain = split.split("[/trend]");
                              var firstSpan = TextSpan(
                                text: splitAgain[0],
                                style: TextStyle(
                                  color: ThemeMe.apply(widget.isThemeDark, DesiredColor.BlueTempo),
                                ),
                              );
                              var secondSpan =
                                  MetarColorize(metar: splitAgain[1], isThemeDark: widget.isThemeDark, context: context)
                                      .getResult;
                              thisSpan.add(firstSpan);
                              thisSpan.add(secondSpan);
                              myWeatherRows.add(
                                Container(
                                  padding: EdgeInsets.only(left: 8, top: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.play_arrow,
                                        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.BlueTempo),
                                        size: 16,
                                      ),
                                      Padding(padding: EdgeInsets.only(left: 2)),
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(children: thisSpan),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              List<TextSpan> thisSpan = <TextSpan>[];
                              thisSpan.add(
                                  MetarColorize(metar: split, isThemeDark: widget.isThemeDark, context: context)
                                      .getResult);
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
                        } else {
                          wxSpan =
                              MetarColorize(metar: myTaforString, isThemeDark: widget.isThemeDark, context: context)
                                  .getResult;
                          myWeatherLineWidget = RichText(text: wxSpan!);
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

                      if (item is MetarTimes) {
                        PrettyTimeCombination? metarTimeFinal;
                        Color? clockIconColor;

                        // DEBUG TIMES HERE
                        // item.metarTimes[0] = DateTime.utc(2019, 8, 19, 19, 10);

                        if (!item.error) {
                          try {
                            var myPrettyDuration = PrettyDuration(
                                referenceTime: item.metarTimes[0], header: "METAR", prettyType: PrettyType.metar);
                            metarTimeFinal = myPrettyDuration.getDuration;
                            clockIconColor = metarTimeFinal!.prettyColor;
                          } catch (e) {
                            clockIconColor = Colors.red;
                          }
                        } else {
                          clockIconColor = Colors.red;
                        }
                        return ListTile(
                          title: Container(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.access_time,
                                  color: clockIconColor,
                                ),
                                Padding(padding: EdgeInsets.only(right: 15)),
                                Flexible(
                                  child: Text(
                                    item.error ? "(no time information)" : metarTimeFinal!.prettyDuration,
                                    style: item.error
                                        ? TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.red,
                                          )
                                        : TextStyle(
                                            fontSize: 14,
                                            color: metarTimeFinal!.prettyColor,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (item is TaforTimes) {
                        PrettyTimeCombination? taforTimeFinal;
                        Color? clockIconColor;

                        if (!item.error) {
                          try {
                            var myPrettyDuration = PrettyDuration(
                                referenceTime: item.taforTimes[0], header: "TAFOR", prettyType: PrettyType.tafor);
                            taforTimeFinal = myPrettyDuration.getDuration;
                            clockIconColor = taforTimeFinal!.prettyColor;
                          } catch (e) {
                            clockIconColor = Colors.red;
                          }
                        } else {
                          clockIconColor = Colors.red;
                        }
                        return ListTile(
                          title: Container(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.access_time,
                                  color: clockIconColor,
                                ),
                                Padding(padding: EdgeInsets.only(right: 15)),
                                Flexible(
                                  child: Text(
                                    item.error ? "(no time information)" : taforTimeFinal!.prettyDuration,
                                    style: item.error
                                        ? TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.red,
                                          )
                                        : TextStyle(
                                            fontSize: 14,
                                            color: taforTimeFinal!.prettyColor,
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
                    }
                    // Should not arrive here, if all AirportWeather
                    // items are properly coded
                    return null;
                  },
                  childCount: wxModel.wxModelList[i].airportFound ? wxModel.wxModelList[i].airportWeather.length : 1,
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

  void _updateTimes() {
    //print("UPDATING WX TICKER: ${DateTime.now().toUtc()}");
    if (_myWeatherList.isNotEmpty) {
      setState(() {
        // This will trigger a refresh of weather times
      });
    }
  }

  Future<void> fabCallback() async {
    widget.callback(SizedBox.shrink());
  }

  void _restoreSharedPreferences() async {
    SharedPreferencesModel().getWeatherUserInput().then((onValue) {
      setState(() {
        _myTextController.text = onValue;
      });
    });

    SharedPreferencesModel().getWeatherInformation().then((onValue) {
      if (onValue.isNotEmpty) {
        setState(() {
          _myWeatherList = wxJsonFromJson(onValue);
        });
      }
    });

    SharedPreferencesModel().getWeatherRequestedAirports().then((onValue) {
      _myRequestedAirports = onValue;
    });

    SharedPreferencesModel().getWeatherHoursBefore().then((onValue) {
      _hoursBefore = onValue;
    });
  }

  void _restoreHoursBefore() async {
    SharedPreferencesModel().getWeatherHoursBefore().then((onValue) {
      _hoursBefore = onValue;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _myTextController.dispose();
    _myMainScrollController.dispose();
    super.dispose();
  }

  void _fetchButtonPressed(BuildContext context, bool fetchBoth) {
    _myRequestedAirports.clear();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _apiCall = true;
      });
      //_callWeatherApi(fetchBoth).then((weatherJson) {
      _callWeatherApi().then((weatherJson) {
        setState(() {
          _apiCall = false;
          if (weatherJson != null) {
            _myWeatherList = weatherJson;
          }
        });
      });
    }
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void onInputTextChange() {
    // REST CANCELLED AS IT WAS CREATING ISSUES
    String textEntered = _myTextController.text;

    /*
    // Ensure that submitted airports are split correctly
    String textEntered = _myTextController.text;
    // Don't do anything if we are deleting text!
    if (textEntered.length > _userSubmitText.length) {
      if (textEntered.length > 3) {
        // Take a look at the last 4 chars entered
        String lastFourChars =
            textEntered.substring(textEntered.length - 4, textEntered.length);
        // If there is at least a space, do nothing
        bool spaceNeeded = true;
        for (String char in lastFourChars.split("")) {
          if (char == " ") {
            spaceNeeded = false;
          }
        }
        if (spaceNeeded) {
          _myTextController.value = TextEditingValue(
              text: textEntered + " ",
              selection: TextSelection.fromPosition(
                  TextPosition(
                      offset: (textEntered + " ").length)
              ),
          );
        }
      }
    }
   */

    _userSubmitText = textEntered;
  }

  Future<List<WxJson>?> _callWeatherApi() async {
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

    var wxExportedJson = <WxJson>[];
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      widget.hideBottomNavBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oops! No Internet connection!',
              style: TextStyle(
                color: Colors.black,
              )),
          backgroundColor: Colors.red[100],
          duration: Duration(seconds: 5),
        ),
      );

      Timer(Duration(seconds: 6), () => widget.showBottomNavBar());
      return null;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fetching WEATHER, hold position!"),
          duration: Duration(seconds: 5),
        ),
      );

      var airports = allAirports.split(',');

      int internalHoursBefore;
      if (_hoursBefore == 0) {
        _mostRecent = true;
        internalHoursBefore = 10;
      } else {
        _mostRecent = false;
        internalHoursBefore = _hoursBefore;
      }

      // Get raw for all airports
      for (var i = 0; i < airports.length; i++) {
        var wxJson = WxJson();
        wxJson.metars = <Metar>[];
        wxJson.tafors = <Tafor>[];
        wxJson.fullAirportDetails = FullAirportDetails();
        wxJson.airportNotFound = true;

        // Get airport information and convert IATA/ICAO
        var icao = "";
        var iata = "";
        if (airports[i].length == 3) {
          iata = airports[i];
          wxJson.fullAirportDetails!.iataCode = iata;
          for (var line in widget.airports) {
            if (line[1] == airports[i].toUpperCase()) {
              icao = line[0];
              airports[i] = icao;
              wxJson.fullAirportDetails!.name = line[2];
              wxJson.airportNotFound = false;
              break;
            }
          }
        } else if (airports[i].length == 4) {
          for (var line in widget.airports) {
            if (line[0] == airports[i].toUpperCase()) {
              iata = line[1];
              wxJson.fullAirportDetails!.iataCode = iata;
              wxJson.fullAirportDetails!.name = line[2];
              wxJson.airportNotFound = false;
              break;
            }
          }
        } else {
          continue;
        }

        var metarResponses = "";
        var taforResponses = "";

        var metUrl = "https://www.aviationweather.gov/cgi-bin/data/dataserver.php?" +
            "dataSource=metars" +
            "&requestType=retrieve" +
            "&format=xml" +
            "&stationString=" +
            airports[i] +
            "&hoursBeforeNow=$internalHoursBefore" +
            "&mostRecent=$_mostRecent";
        log("WX request URL: $metUrl");
        var metResponse = await http.get(Uri.parse(metUrl)).timeout(Duration(seconds: 10));
        metarResponses = metResponse.body;

        var tafUrl = "https://www.aviationweather.gov/cgi-bin/data/dataserver.php?" +
            "dataSource=tafs" +
            "&requestType=retrieve" +
            "&format=xml" +
            "&stationString=" +
            airports[i] +
            "&hoursBeforeNow=24" +
            "&mostRecent=true" +
            "&timeType=issue";
        log("TAF request URL: $tafUrl");
        var tafResponse = await http.get(Uri.parse(tafUrl)).timeout(Duration(seconds: 10));
        taforResponses = tafResponse.body;

        // Main airport data
        final metarsDocument = XmlDocument.parse(metarResponses);
        try {
          wxJson.airportIdIcao = metarsDocument.findAllElements('station_id').map((node) => node.text).first;
          wxJson.airportIdIata = "";
          wxJson.airportNotFound = false;
        } catch (e) {
          // Initialize to empty object, with only airport information
          wxJson.metars!.add(Metar());
          wxJson.tafors!.add(Tafor());
          wxExportedJson.add(wxJson);
          continue;
        }

        // We add all METARS
        var metarsList = <XmlElement>[];
        var metarsRaw = metarsDocument.findAllElements('METAR').forEach((metar) => metarsList.add(metar));
        //metarsRaw.map((node) => node.text).forEach((metar) => metarsList.add(metar));
        if (metarsList.isNotEmpty) {
          for (var i = 0; i < metarsList.length; i++) {
            var met = Metar();
            met.metar = metarsList[i].findElements('raw_text').map((node) => node.text).first;
            met.metarTime = metarsList[i].findElements('observation_time').map((node) => node.text).first;
            wxJson.metars!.add(met);
          }
        } else {
          wxJson.metars!.add(Metar());
        }

        // We only add first TAF
        var taf = Tafor();
        final taforsDocument = XmlDocument.parse(taforResponses);
        final taforsRaw = taforsDocument.findAllElements('TAF').map((node) => node.text);
        if (taforsRaw.isNotEmpty) {
          taf.tafor = taforsDocument.findAllElements('raw_text').map((node) => node.text).first;
          taf.taforTime = taforsDocument.findAllElements('issue_time').map((node) => node.text).first;
          wxJson.tafors!.add(taf);
        } else {
          wxJson.tafors!.add(Tafor());
        }

        wxExportedJson.add(wxJson);
      }

      //wxExportedJson = wxJsonFromJson(response.body);
      SharedPreferencesModel().setWeatherInformation(wxJsonToJson(wxExportedJson));
      SharedPreferencesModel().setWeatherUserInput(_userSubmitText);
      SharedPreferencesModel().setWeatherRequestedAirports(_myRequestedAirports);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("There was an error with the server or the Internet connection!",
              style: TextStyle(
                color: Colors.black,
              )),
          backgroundColor: Colors.red[100],
          duration: Duration(seconds: 6),
        ),
      );
      return null;
    }

    return wxExportedJson;
  }

  Future<List<WxJson>?> _callWeatherApiOLD(bool fetchBoth) async {
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

    List<WxJson>? wxExportedJson;

    bool wxFailed = false;
    bool notamFailed = false;

    DateTime startRequest = DateTime.now();
    int firstSnackTimeNeeded = 5;

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        widget.hideBottomNavBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oops! No Internet connection!',
                style: TextStyle(
                  color: Colors.black,
                )),
            backgroundColor: Colors.red[100],
            duration: Duration(seconds: firstSnackTimeNeeded),
          ),
        );

        Timer(Duration(seconds: 6), () => widget.showBottomNavBar());
        return null;
      } else {
        String wxServer = ConstVariables.apiURL;
        String wxApi = "Wx/GetWx?";

        String wxSource = "source=Unknown";
        if (Platform.isAndroid) {
          wxSource = "source=Android";
        } else if (Platform.isIOS) {
          wxSource = "source=IOS";
        } else {
          wxSource = "source=Other";
        }
        if (_airportsFromFav > 0) {
          wxSource += "-Fav$_airportsFromFav";
          _airportsFromFav = 0;
        } else {
          wxSource += "-Fav0";
        }
        wxSource += "-v${widget.thisAppVersion}";

        String wxAirports = "&Airports=$allAirports";

        int internalHoursBefore;
        if (_hoursBefore == 0) {
          _mostRecent = true;
          internalHoursBefore = 10;
        } else {
          _mostRecent = false;
          internalHoursBefore = _hoursBefore;
        }

        String mostRecent = "&mostRecent=$_mostRecent";
        String hoursBefore = "&hoursBefore=$internalHoursBefore";

        String wxUrl = wxServer + wxApi + wxSource + wxAirports + mostRecent + hoursBefore;

        String fetchText;
        if (!fetchBoth) {
          fetchText = "Fetching WEATHER, hold position!";
        } else {
          fetchText = "Fetching WEATHER and NOTAM, hold position!";

          if (_myRequestedAirports.length > 6) {
            fetchText += "\n\nToo many NOTAM requested, this might take time! If it fails, "
                "please try with less next time!";
            firstSnackTimeNeeded = 8;
          }
        }
        widget.hideBottomNavBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fetchText),
            duration: Duration(seconds: firstSnackTimeNeeded),
          ),
        );

        final response = await http.post(Uri.parse(wxUrl)).timeout(Duration(seconds: 60));

        if (response.statusCode != 200) {
          wxFailed = true;
        } else {
          wxExportedJson = wxJsonFromJson(response.body);
          SharedPreferencesModel().setWeatherInformation(response.body);
          SharedPreferencesModel().setWeatherUserInput(_userSubmitText);
          SharedPreferencesModel().setWeatherRequestedAirports(_myRequestedAirports);
        }

        if (fetchBoth) {
          String notamServer = ConstVariables.apiURL;
          String notamApi = "Notam/GetNotam?";

          String notamSource = "source=Unknown";
          if (Platform.isAndroid) {
            notamSource = "source=Android";
          } else if (Platform.isIOS) {
            notamSource = "source=IOS";
          } else {
            notamSource = "source=Other";
          }
          if (_airportsFromFav > 0) {
            notamSource += "-Fav$_airportsFromFav";
            _airportsFromFav = 0;
          } else {
            notamSource += "-Fav0";
          }
          notamSource += "-v${widget.thisAppVersion}";

          String notamAirports = "&airports=$allAirports";
          String notamUrl = notamServer + notamApi + notamSource + notamAirports;

          int timeOut = 20 * _myRequestedAirports.length;
          final response = await http.post(Uri.parse(notamUrl)).timeout(Duration(seconds: timeOut));

          if (response.statusCode != 200) {
            notamFailed = true;
          } else {
            var timeNow = DateTime.now().toUtc();
            String notamRequestedTime = timeNow.toIso8601String();

            SharedPreferencesModel().setNotamInformation(response.body);
            SharedPreferencesModel().setNotamUserInput(_userSubmitText);
            SharedPreferencesModel().setNotamRequestedAirports(_myRequestedAirports);
            SharedPreferencesModel().setNotamRequestedTime(notamRequestedTime);
            SharedPreferencesModel().setNotamScrollList(_myRequestedAirports);
          }
        }
      }

      if (wxFailed || notamFailed) {
        throw "error";
      }
    } catch (e) {
      String expString = "";
      if (fetchBoth) {
        if (wxFailed && notamFailed) {
          expString = "Fetching failed both for WX and NOTAM, please try again later!";
        } else if (wxFailed) {
          expString = "Fetching failed for WX, but NOTAM were proccessed!";
        } else if (notamFailed) {
          expString = "WEATHER was proceessed, but fetching failed for NOTAM!";
        } else {
          expString = "There was an error with the server or the Internet connection!";
        }
      } else {
        if (wxFailed) {
          expString = "Failed fetching WEATHER, please try again later!";
        } else {
          expString = "There was an error with the server or the Internet connection!";
        }
      }

      widget.hideBottomNavBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(expString,
              style: TextStyle(
                color: Colors.black,
              )),
          backgroundColor: Colors.red[100],
          duration: Duration(seconds: 6),
        ),
      );

      // This handles when we show the BottomNavBar again
      // This ensures that we wait for the first SnackBar (normally 4 + 1) seconds
      // and then we add another 6 + 1 for the error, but we check
      // previously if the wait has to be increased as the first one has not
      // yet been on screen for 5 seconds
      DateTime finishRequest = DateTime.now();
      int diffTime = finishRequest.difference(startRequest).inSeconds;
      int myWait;
      if (diffTime <= firstSnackTimeNeeded) {
        myWait = firstSnackTimeNeeded - diffTime + 7; // First SnackBar - time until now + time for the second one
      } else {
        myWait = 7; // If more time has elapsed, just wait 6 + 1 seconds for the error SnackBar
      }
      Timer(Duration(seconds: myWait), () => widget.showBottomNavBar());

      return null;
    }

    // This handles when we show the BottomNavBar again
    // and tries to decrease the time if elapse time has already counted
    // for more than 5 seconds (in which case we just show it again)
    DateTime finishRequest = DateTime.now();
    int diffTime = finishRequest.difference(startRequest).inSeconds;
    int myWait = 0;
    if (diffTime < firstSnackTimeNeeded) {
      myWait = (firstSnackTimeNeeded - diffTime).round();
    }
    Timer(Duration(seconds: myWait), () => widget.showBottomNavBar());

    return wxExportedJson;
  }

  _showSettings() async {
    return showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return WeatherOptionsDialog(hours: _hoursBefore, hoursChangedCallback: _hoursBeforeChanged);
        });
  }

  void _hoursBeforeChanged(double newValue) {
    _hoursBefore = newValue.toInt();
  }

  void onMainScrolled() {
    widget.notifyScrollPosition(_myMainScrollController.offset);
  }
}
