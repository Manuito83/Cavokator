import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'package:cavokator_flutter/json_models/notam_json.dart';
import 'package:cavokator_flutter/utils/theme_me.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';
import 'package:cavokator_flutter/private.dart';
import 'package:cavokator_flutter/notam/notam_item_builder.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class NotamPage extends StatefulWidget {
  // TODO: BUG: try SVQ+JFK. Switch to WX page. Back to NOTAM. Order is opposite.
  final bool isThemeDark;

  NotamPage({@required this.isThemeDark});

  @override
  _NotamPageState createState() => _NotamPageState();
}

class _NotamPageState extends State<NotamPage> {
  final _formKey = GlobalKey<FormState>();
  final _myTextController = new TextEditingController();

  String _userSubmitText;
  List<String> _myRequestedAirports = new List<String>();
  List<NotamJson> _myNotamList = new List<NotamJson>();
  bool _apiCall = false;

  // Google Maps API
  Completer<GoogleMapController> _mapsController = Completer();
  void _onMapCreated(GoogleMapController controller) {
    _mapsController.complete(controller);
  }

  AutoScrollController _scrollController;
  final _scrollDirection = Axis.vertical;
  int _scrollCounter = -1;
  int _scrollTotal = 0;

  @override
  void initState() {
    super.initState();
    _restoreSharedPreferences();

    _scrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: _scrollDirection,
    );

    _userSubmitText = _myTextController.text;
    _myTextController.addListener(onInputTextChange);
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
            controller: _scrollController,
          ),
        );
      },
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = new List<Widget>();

    slivers.add(_myAppBar());
    slivers.add(_inputForm());

    var notamSect = _notamSections();
    for (var section in notamSect) {
      slivers.add(section);
    }

    return slivers;
  }

  Widget _myAppBar() {
    return SliverAppBar(
      iconTheme: new IconThemeData(color: Colors.black),
      title: Text(
        "NOTAM",
        style: TextStyle(color: Colors.black),
      ),
      expandedHeight: 150,
      // TODO: Settings option (value '0' if inactive)
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/notam_header.jpg'),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.keyboard_arrow_up),
          color: Colors.black,
          onPressed: _scrollToIndex
        ),
        IconButton(
          icon: Icon(Icons.settings),
          color: Colors.black,
          onPressed: () {
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
                            _myNotamList.clear();
                            _scrollTotal = 0;
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

  List<Widget> _notamSections() {
    List<Widget> mySections = List<Widget>();

    if (_apiCall) {
      mySections.add(
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) =>
            Row(
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
      if (_myNotamList.isNotEmpty) {
        var notamBuilder = NotamItemBuilder(jsonNotamList: _myNotamList);
        var notamModel = notamBuilder.result;

        for (var i = 0; i < notamModel.notamModelList.length; i++) {

          var airportName =
          notamModel.notamModelList[i].airportHeading == null ?
          _myRequestedAirports[i].toUpperCase() :
          notamModel.notamModelList[i].airportHeading;

          int thisChildCount;
          if (notamModel.notamModelList[i].airportNotams.length == 0) {
            thisChildCount = 1;
          }
          else {
            thisChildCount = notamModel.notamModelList[i].airportNotams.length;
          }

          // This is where the scroll will end up for every airport
          _scrollTotal = notamModel.notamModelList.length;
          mySections.add(_scrollToBar(i));

          mySections.add(SliverStickyHeaderBuilder(
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
                            airportName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (notamModel.notamModelList[i].airportNotFound) {
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
                  }
                  else if (notamModel.notamModelList[i].airportWithNoNotam) {
                    return ListTile(
                      title: Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                          child: RichText(
                            text: TextSpan(
                              text: "No NOTAM published here!",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  else {
                    final item = notamModel.notamModelList[i].airportNotams[index];
                    if (item is NotamSingle){
                      return ListTile(
                        title: Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                            child: notamSingleCard(item),
                          ),
                        ),
                      );
                    }
                    else if (item is NotamCategory) {
                      return ListTile(
                        title: notamCategoryCard(item),
                      );
                    }
                  }
                },
                  childCount: thisChildCount,
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

  Widget notamCategoryCard (NotamCategory thisCategory) {
    final category = thisCategory.mainCategory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Card(
          margin: EdgeInsets.only(top: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Colors.deepPurple,
              width: 2,
            ),
          ),
          elevation: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
              ),
              Flexible(
                child: Text(category),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 20, 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget notamSingleCard (NotamSingle thisNotam) {

    final notamId = thisNotam.id;
    final notamCategorySubMain = thisNotam.categorySubMain;
    final notamCategorySubSecondary = thisNotam.categorySubSecondary;
    final notamFreeText = thisNotam.freeText;
    final notamMainCategory = thisNotam.mainCategory;

    Widget myMapWidget;
    if (thisNotam.latitude != null) {
      myMapWidget = IconButton(
        icon: Icon(Icons.map),
        color: Colors.black,
        onPressed: () {
          _showMap();
        },
      );
    } else {
      myMapWidget = SizedBox.shrink();
    }

    Widget subCategoriesWidget;
    if (thisNotam.categorySubMain != "" && thisNotam.categorySubSecondary != "") {
      subCategoriesWidget = Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(notamCategorySubMain,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.play_arrow,
                      color: Colors.black,
                      size: 12,
                    ),
                  ),
                  Text(notamCategorySubSecondary,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    else if (thisNotam.categorySubMain != "") {
      subCategoriesWidget = Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            Text(notamCategorySubMain,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );
    }
    else {
      subCategoriesWidget = SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              notamId,
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 16,
              ),
            ),
            myMapWidget,
          ],
        ),
        subCategoriesWidget,
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(notamFreeText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _scrollToBar (int j) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          child: Padding (
            padding: EdgeInsets.all(0),
            child: AutoScrollTag(
              key: ValueKey(j),
              controller: _scrollController,
              index: j,
              highlightColor: Colors.green.withOpacity(1),
              child: Text(""),
            ),
          ),
        ),
        childCount: 1,
      ),
    );
  }

  void _restoreSharedPreferences() {
    SharedPreferencesModel().getNotamUserInput().then((onValue) {
      setState(() {
        _myTextController.text = onValue;
      });
    });


    SharedPreferencesModel().getNotamInformation().then((onValue) {
      if (onValue.isNotEmpty){
        setState(() {
          _myNotamList = notamJsonFromJson(onValue);
        });
      }
    });

  }

  void _fetchButtonPressed(BuildContext context) {
    _myRequestedAirports.clear();
    _scrollTotal = 0;

    if (_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Fetching NOTAMS, hold position!'),
        ),
      );
      setState(() {
        _apiCall = true;
      });

      _callNotamApi().then((weatherJson) {
        setState(() {
          _apiCall = false;
          if (weatherJson != null) {
            _myNotamList = weatherJson;

            // Sorting list, because it might not be sorted from the API
            var newList = List<NotamJson>();
            for (var i = 0; i < _myRequestedAirports.length; i++) {
              for (var n in _myNotamList) {
                if (_myRequestedAirports[i].toUpperCase() == n.airportIdIata ||
                    _myRequestedAirports[i].toUpperCase() == n.airportIdIcao) {
                  newList.add(n);
                  break;
                }
              }
            }
            _myNotamList = newList;
          }
        });
      });

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

  Future<List<NotamJson>> _callNotamApi() async {
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
    String api = "Notam/GetNotam?";
    String source = "source=Cavokator";
    String airports = "&airports=$allAirports";
    String url = server + api + source + airports;

    List<NotamJson> exportedJson;
    try {
      // TODO: different durations depending on number of airports?
      final response = await http.post(url).timeout(Duration(seconds: 30));
      if (response.statusCode != 200) {
        // TODO: this error is OK, but what about checking Internet connectivity as well??
        // TODO: message for > 3 airports?
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
      exportedJson = notamJsonFromJson(response.body);
      SharedPreferencesModel().setNotamInformation(response.body);
      SharedPreferencesModel().setNotamUserInput(_userSubmitText);
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

  Future<void> _showMap() async {
    const LatLng _center = const LatLng(45.521563, -122.677433);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5),
          title: Text('Rewind and remember'),
          content: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Nice!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future _scrollToIndex() async {
    _scrollCounter++;
    if (_scrollCounter >= _scrollTotal) {
      _scrollCounter = 0;
    }

    print("scrollCounter: $_scrollCounter");
    print("scrollTotal: $_scrollTotal");

    // We need to scroll first quickly to the next item so that the one we
    // want is shown on the screen (very quick). Otherwise, scrolling
    // directly to "_scrollCounter" will not be precise.
    int maxCorrection = 0;
    if (_scrollTotal - 1 - _scrollCounter > 1){
      maxCorrection = 2;
    }
    else if (_scrollTotal - 1 - _scrollCounter > 0){
      maxCorrection = 1;
    }
    await _scrollController.scrollToIndex(maxCorrection,
        duration: Duration(milliseconds: 100),
        preferPosition: AutoScrollPosition.end);

    // This is the actual item we want
    await _scrollController.scrollToIndex(_scrollCounter,
        duration: Duration(seconds: 2),
        preferPosition: AutoScrollPosition.begin);

    _scrollController.highlight(_scrollCounter);
  }


}