import 'package:flutter/animation.dart';
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
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:cavokator_flutter/utils/pretty_duration.dart';
import 'package:cavokator_flutter/notam/notam_custom_popup.dart';
import 'package:share/share.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:io';

class NotamPage extends StatefulWidget {

  final bool isThemeDark;
  final Widget myFloat;
  final Function callback;
  final bool showHeaders;
  final Function hideBottomNavBar;
  final Function showBottomNavBar;
  final double recalledScrollPosition;
  final Function notifyScrollPosition;

  NotamPage({@required this.isThemeDark, @required this.myFloat,
             @required this.callback, @required this.showHeaders,
             @required this.hideBottomNavBar, @required this.showBottomNavBar,
             @required this.recalledScrollPosition,
             @required this.notifyScrollPosition});

  @override
  _NotamPageState createState() => _NotamPageState();
}

class _NotamPageState extends State<NotamPage> {
  final _formKey = GlobalKey<FormState>();
  final _myTextController = new TextEditingController();

  String _requestedTime;
  Timer _ticker;

  bool _sortByCategories = true;

  String _userSubmitText;
  List<String> _myRequestedAirports = new List<String>();
  List<NotamJson> _myNotamList = new List<NotamJson>();
  bool _apiCall = false;

  String mySharedNotam = "";

  //int _initialPopupValue = 0;
  // ^^ this is not working yet, see:
  // https://github.com/flutter/flutter/issues/19954
  // when working, it should highlight what's active
  List<CustomNotamPopup> _popupChoices = <CustomNotamPopup>[
    CustomNotamPopup(title: 'Sort by category'),
    CustomNotamPopup(title: 'Sort by number'),
  ];

  // Google Maps API - Not necessary??
  //GoogleMapController _mapController;

  AutoScrollController _mainScrollController;
  final _scrollDirection = Axis.vertical;
  List<String> _scrollList = List<String>();

  @override
  void initState() {
    super.initState();

    _restoreSharedPreferences();
    SharedPreferencesModel().setSettingsLastUsedSection("1");

    _ticker = new Timer.periodic(Duration(minutes: 1), (Timer t) => _updateTimes());

    // Delayed callback for FAB
    Future.delayed(Duration.zero, () => fabCallback(init: true));

    _userSubmitText = _myTextController.text;
    _myTextController.addListener(onInputTextChange);

    _mainScrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: _scrollDirection,
    );

    _mainScrollController.addListener(onMainScrolled);

    // TODO (maybe?): setting to deactivate this?
    Future.delayed(Duration(milliseconds: 500), () {
      _mainScrollController.animateTo(
        widget.recalledScrollPosition,
        duration: Duration(milliseconds: 1500),
        curve: Curves.decelerate,
      );
    });
  }

  @override
  Future dispose() async {
    _ticker?.cancel();
    _myTextController.dispose();
    _mainScrollController.dispose();
    super.dispose();
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
            controller: _mainScrollController,
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


  Future<void> fabCallback({bool init = false, bool clear = false}) async {
    // This shared preference recall is here because otherwise
    // it would execute after the FAB loads
    if (init) {
      await SharedPreferencesModel().getNotamScrollList().then((onValue) {
        setState(() {
          _scrollList = onValue;
        });
      });
    }

    if (_myNotamList.length > 0 && !clear){
      widget.callback(SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        overlayColor: Colors.grey[800],
        overlayOpacity: 0.5,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        visible: true,
        children:
          _mySpeedDials(),
      ));
    }
    else {
      widget.callback(SpeedDial(
        overlayColor: Colors.grey[800],
        overlayOpacity: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        visible: false,
      ));
    }
  }

  Widget _myAppBar() {
    return SliverAppBar(
      iconTheme: new IconThemeData(
        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
      ),
      title: Text(
        "NOTAM",
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
              image: new AssetImage('assets/images/notam_header.jpg'),
              fit: BoxFit.fitWidth,
              colorFilter: widget.isThemeDark == true
                  ? ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
                  : null,
            ),
          ),
        ),
      ),
      actions: <Widget>[
        PopupMenuButton<CustomNotamPopup>(
          icon: Icon(
            Icons.sort,
            color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          ),
          //initialValue: _popupChoices[_initialPopupValue],
          onSelected: _selectCategoryMenu,
          itemBuilder: (BuildContext context) {
            return _popupChoices.map((CustomNotamPopup choice) {
              return PopupMenuItem<CustomNotamPopup>(
                value: choice,
                child: Text(choice.title),
              );
            }).toList();
          },
        ),
        IconButton(
          icon: Icon(Icons.share),
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          onPressed: () {
            Share.share(mySharedNotam);
          },
        ),
      ],
    );
  }

  void _selectCategoryMenu(CustomNotamPopup choice){
    setState(() {
      if (choice == _popupChoices[0]){
        _sortByCategories = true;
        //_initialPopupValue = 0;
      } else {
        _sortByCategories = false;
        //_initialPopupValue = 1;
      }
    });


    String mText;
    _sortByCategories 
      ? mText = "Sorting by categories!" 
      : mText = "Sorting by NOTAM number & date!";

    widget.hideBottomNavBar(5);
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(mText),
        duration: Duration(seconds: 4),
      ),
    );

    SharedPreferencesModel().setNotamCategorySorting(_sortByCategories);
    
  }

  Widget _inputForm() {
    return CustomSliverSection(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                        AssetImage("assets/icons/drawer_notam.png"),
                        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      ),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
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
                            /*
                            if (_myRequestedAirports.length > 6) {
                              return "Too many airports (max is 6)!";
                            }
                            */
                            return null;
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
                      ButtonTheme(
                        minWidth: 1.0,
                        buttonColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.Buttons),
                        child: RaisedButton(
                          child: ImageIcon(
                              AssetImage("assets/icons/drawer_notam.png"),
                              color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText)
                          ),
                          onPressed: ()  {
                            _fetchButtonPressed(context, false);
                          },
                        ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                      ButtonTheme(
                        minWidth: 1.0,
                        buttonColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.Buttons),
                        child: RaisedButton(
                          child: Row(
                            children: <Widget>[
                              ImageIcon(
                                AssetImage("assets/icons/drawer_notam.png"),
                                color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                              ),
                              Text(" + "),
                              ImageIcon(
                                AssetImage("assets/icons/drawer_wx.png"),
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
                      ButtonTheme(
                        minWidth: 1.0,
                        buttonColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.Buttons),
                        child:  RaisedButton(
                          child: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _apiCall = false;
                              _myNotamList.clear();
                              _scrollList.clear();
                              fabCallback();
                              SharedPreferencesModel().setNotamUserInput("");
                              SharedPreferencesModel().setNotamInformation("");
                              _myTextController.text = "";
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

        var notamBuilder = NotamItemBuilder(jsonNotamList: _myNotamList,
                                            sortCategories: _sortByCategories);
        var notamModel = notamBuilder.result;

        mySharedNotam = "";
        mySharedNotam += "###";
        mySharedNotam += "\n### CAVOKATOR NOTAMS ###";
        mySharedNotam += "\n###";
        for (var a = 0; a < notamModel.notamModelList.length; a++){
          var airportName =
            notamModel.notamModelList[a].airportHeading == null
            ? _myRequestedAirports[a].toUpperCase()
            : notamModel.notamModelList[a].airportHeading;
          mySharedNotam += "\n\n\n### $airportName ###";
          if (notamModel.notamModelList[a].airportNotFound){
            mySharedNotam += "\n\nERROR: AIRPORT NOT FOUND!";
          }
          if (notamModel.notamModelList[a].airportWithNoNotam){
            mySharedNotam += "\n\nNo NOTAM found in this airport!";
          }
          for (var b = 0; b < notamModel.notamModelList[a].airportNotams.length; b++) {
            var thisItem = notamModel.notamModelList[a].airportNotams[b];

            if (thisItem is NotamCategory){
              mySharedNotam += "\n\n## ${thisItem.mainCategory}";
            } else if (thisItem is NotamSingle) {
              mySharedNotam += "\n\n***\n${thisItem.raw}\n***";
            }
          }
        }
        mySharedNotam += "\n\n\n\n ### END CAVOKATOR REPORT ###";

        DateTime myRequestedTime = DateTime.parse(_requestedTime);
        PrettyDuration myPrettyDuration = PrettyDuration(
          referenceTime: myRequestedTime,
          header: "Requested",
          prettyType: PrettyType.notam
        );
        PrettyTimeCombination myFinalDuration = myPrettyDuration.getDuration;

        mySections.add(
          CustomSliverSection(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                    child: Text(myFinalDuration.prettyDuration,
                      style: TextStyle(
                        color: myFinalDuration.prettyColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

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
          mySections.add(_scrollToBar(i));

          mySections.add(SliverStickyHeaderBuilder(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Container(
                    margin: EdgeInsetsDirectional.only(bottom: 25),
                    height: 60.0,
                    color: (state.isPinned ? ThemeMe.apply(widget.isThemeDark, DesiredColor.HeaderPinned)
                        : ThemeMe.apply(widget.isThemeDark, DesiredColor.HeaderUnpinned)
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
                            "(${_myRequestedAirports[i].toUpperCase()}) " +
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
                      bool colorBorderActive = false;
                      Color colorBorderValue = ThemeMe.apply(
                          widget.isThemeDark,
                          DesiredColor.MainText);

                      // WARNING IN ORANGE
                      if (item.categorySubMain == "Air display" ||
                          item.categorySubMain == "Aerobatics" ||
                          item.categorySubMain == "Captive balloon or kite" ||
                          item.categorySubMain == "Demolition of explosives" ||
                          item.categorySubMain == "Exercises" ||
                          item.categorySubMain == "Air refueling" ||
                          item.categorySubMain == "Glider flying" ||
                          item.categorySubMain == "Blasting" ||
                          item.categorySubMain == "Banner/target towing" ||
                          item.categorySubMain == "Ascent of free balloon" ||
                          item.categorySubMain == "Missile, gun or rocket firing" ||
                          item.categorySubMain == "Parachute jumping exercise" ||
                          item.categorySubMain == "Radioactive/toxic materials" ||
                          item.categorySubMain == "Burning or blowing gas" ||
                          item.categorySubMain == "Mass movement of aircraft" ||
                          item.categorySubMain == "Unmanned aircraft" ||
                          item.categorySubMain == "Formation flight" ||
                          item.categorySubMain == "Significant volcanic activity" ||
                          item.categorySubMain == "Aerial survey" ||
                          item.categorySubMain == "Model flying") {

                        colorBorderActive = true;
                        colorBorderValue = Colors.orange;
                      }

                      // THIS EARNING IN RED
                      if (item.categorySubMain == "Runway"
                          && item.categorySubSecondary == "Closed") {
                        colorBorderActive = true;
                        colorBorderValue = Colors.red;
                      }

                      return ListTile(
                        title: Card(
                          shape: colorBorderActive
                              ? new RoundedRectangleBorder(
                              side: new BorderSide(color: colorBorderValue, width: 2.0),
                              borderRadius: BorderRadius.circular(4.0))
                              : null,
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                            child: item.notamQ
                                ? notamQSingleCard(item, airportName)
                                : notamOtherSingleCard(item),
                          ),
                        ),
                      );
                    }
                    else if (item is NotamCategory) {
                      if (_sortByCategories) {
                        return ListTile(
                          title: notamCategoryCard(item),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }
                  }
                  // Should not arrive here if all NotamGeneric items
                  // are properly coded
                  return null;
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
        SharedPreferencesModel().setNotamScrollList(_scrollList);
      }
      else {
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
              color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MagentaCategory),
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

  Widget notamQSingleCard (NotamSingle thisNotam, String thisAirportName) {

    final notamId = thisNotam.id;
    final notamCategorySubMain = thisNotam.categorySubMain;
    final notamCategorySubSecondary = thisNotam.categorySubSecondary;
    final notamFreeText = thisNotam.freeText;
    final notamRaw = thisNotam.raw;

    Widget myMapWidget() {
      if (thisNotam.latitude != null) {
        return IconButton(
          icon: Icon(Icons.map),
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          onPressed: () {
            _showMap(
                notamId: thisNotam.id,
                latitude: thisNotam.latitude,
                longitude: thisNotam.longitude,
                radius: thisNotam.radius
            );
          },
        );
      } else {
        return SizedBox.shrink();
      }
    }

    Widget subCategoriesWidget(){
      if (thisNotam.categorySubMain != "" && thisNotam.categorySubSecondary != "") {
        return Padding(
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
                        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                        size: 12,
                      ),
                    ),
                    Text(
                      notamCategorySubSecondary,
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
      } else if (thisNotam.categorySubMain != "") {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              Text(notamCategorySubMain,
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeMe.apply(widget.isThemeDark, DesiredColor.BlueTempo),
                ),
              ),
            ],
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    }

    Widget datesAndTimesWidget(){
      bool notamValid = false;
      DateTime now = DateTime.now().toUtc();
      if (!thisNotam.permanent){
        if (thisNotam.startTime.isBefore(now) && thisNotam.endTime.isAfter(now)){
          notamValid = true;
        }
      } else {
          if (thisNotam.startTime.isBefore(now)){
            notamValid = true;
          }
      }

      // Time formatting
      var formatter = new DateFormat('yyyy-MMM-dd HH:mm');
      String startTime = formatter.format(thisNotam.startTime);

      String notamEnd;
      if (thisNotam.permanent){
        notamEnd = "PERMANENT";
      } else if (thisNotam.estimated){
        notamEnd = formatter.format(thisNotam.endTime) + " (EST)";
      } else {
        notamEnd = formatter.format(thisNotam.endTime);
      }

      return Row(
        children: <Widget>[
          Icon(Icons.today,
            color: notamValid
                ? Colors.red[300]
                : ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
            size: 18,
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(startTime,
                style: TextStyle(
                fontSize: 11,
                ),
              ),
            ),
          ),
          Icon(Icons.play_arrow,
            color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
            size: 12,
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: Text(notamEnd,
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget timesActiveWidget() {
      if (thisNotam.validTimes == "") {
        return SizedBox.shrink();
      } else {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(Icons.alarm,
                color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                size: 18,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(thisNotam.validTimes,
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    Widget bottomTopLimitsWidget() {
      Widget bottomIcon;
      Widget bottomText;

      if (thisNotam.bottomLimit != "") {
        bottomIcon = Icon(
          Icons.vertical_align_bottom,
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          size: 18,
        );
        bottomText = Flexible(
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                child: Text(thisNotam.bottomLimit,
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
        );
      } else {
        bottomIcon = SizedBox.shrink();
        bottomText = SizedBox.shrink();
      }

      Widget middlePadding;
      Widget topIcon;
      Widget topText;
      if (thisNotam.topLimit != "") {
        double mPad;
        thisNotam.bottomLimit != "" ? mPad = 15 : mPad = 0;
        middlePadding = Padding (
          padding: EdgeInsets.symmetric(horizontal: mPad)
        );
        topIcon = Icon(
          Icons.vertical_align_top,
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          size: 18,
        );
        topText = Flexible(
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Text(thisNotam.topLimit,
              style: TextStyle(
                fontSize: 11,
              ),
            ),
          ),
        );
      } else {
        middlePadding = SizedBox.shrink();
        topIcon = SizedBox.shrink();
        topText = SizedBox.shrink();
      }

      double myPadding = 0;
      if (thisNotam.bottomLimit != ""|| thisNotam.topLimit != ""){
        myPadding = 10;
      }
      return Padding(
        padding: EdgeInsets.symmetric(vertical: myPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            bottomIcon,
            bottomText,
            middlePadding,
            topIcon,
            topText,
          ]
        ),
      );
    }

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              child: Text(
                notamId,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                _showFullNotam(notamId, notamRaw);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                myMapWidget(),
                IconButton(
                  icon: Icon(Icons.share),
                  color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                  onPressed: () {
                    Share.share(_shareThisNotam(thisNotam, thisAirportName));
                  },
                ),
              ],
            ),
          ],
        ),
        subCategoriesWidget(),
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
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: datesAndTimesWidget(),
              ),
            ],
          ),
        ),
        timesActiveWidget(),
        bottomTopLimitsWidget(),
      ],
    );
  }

  Widget notamOtherSingleCard (NotamSingle thisNotam) {

    final notamRaw = thisNotam.raw;

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(notamRaw),
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
              controller: _mainScrollController,
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

  void _restoreSharedPreferences() async {
    try {
      List<String> req = List<String>(); // Save correct order for later
      await SharedPreferencesModel().getNotamUserInput().then((onValue) {
        req = onValue.split(" ");
        setState(() {
          _myTextController.text = onValue;
        });
      });

      await SharedPreferencesModel().getNotamInformation().then((onValue) {
        if (onValue.isNotEmpty){
          // We need to sort based on user request, as most probably the
          // order or airports in the NOTAM string is not correct
          var newList = List<NotamJson>();
          var savedJson = notamJsonFromJson(onValue);
          for (var i = 0; i < req.length; i++) {
            for (var n in savedJson) {
              if ((req[i].length == 3 && req[i].toUpperCase() == n.airportIdIata) ||
                  (req[i].length == 4 && req[i].toUpperCase() == n.airportIdIcao)) {
                newList.add(n);
                break;
              }
            }
          }
          _myNotamList = newList;
        }
      });

      await SharedPreferencesModel().getNotamRequestedAirports().then((onValue) {
        _myRequestedAirports = onValue;
      });

      await SharedPreferencesModel().getNotamRequestedTime().then((onValue) {
        _requestedTime = onValue;
      });

      await SharedPreferencesModel().getNotamCategorySorting().then((onValue) {
          _sortByCategories = onValue;
      });

    } catch (except) {
      // pass
    }
  }

  void _fetchButtonPressed(BuildContext context, bool fetchBoth) {
    // We clear _myRequestedAirports will be dealt with from here
    // through the form validator. We clear it here so that we don't get
    // any repetitions later
    _myRequestedAirports.clear();
    fabCallback(clear: true);

    if (_formKey.currentState.validate()) {
      setState(() {
        _apiCall = true;
      });

      _callNotamApi(fetchBoth).then((weatherJson) {
        setState(() {
          _apiCall = false;
          if (weatherJson != null) {
            _myNotamList = weatherJson;

            // Sorting list, because it might not be sorted from the API
            var sortedList = List<NotamJson>();
            for (var i = 0; i < _myRequestedAirports.length; i++) {
              for (var n in _myNotamList) {
                if (_myRequestedAirports[i].toUpperCase() == n.airportIdIata ||
                    _myRequestedAirports[i].toUpperCase() == n.airportIdIcao) {
                  sortedList.add(n);
                  break;
                }
              }
            }
            _myNotamList = sortedList;
          }
          fabCallback();
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
    _userSubmitText = textEntered;
  }


  Future<List<NotamJson>> _callNotamApi(bool fetchBoth) async {
    String allAirports = "";

    _scrollList.clear();

    if (_myRequestedAirports.isNotEmpty) {
      for (var i = 0; i < _myRequestedAirports.length; i++) {
        if (i != _myRequestedAirports.length - 1) {
          allAirports += _myRequestedAirports[i] + ",";
        } else {
          allAirports += _myRequestedAirports[i];
        }
        _scrollList.add(_myRequestedAirports[i]);
      }
    }

    List<NotamJson> notamExportedJson;

    bool wxFailed = false;
    bool notamFailed = false;

    DateTime startRequest = DateTime.now();
    int firstSnackTimeNeeded = 5;

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        widget.hideBottomNavBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Oops! No Internet connection!',
                style: TextStyle(
                  color: Colors.black,
                )
            ),
            backgroundColor: Colors.red[100],
            duration: Duration(seconds: firstSnackTimeNeeded),
          ),
        );

        Timer(Duration(seconds: 6), () => widget.showBottomNavBar());
        return null;

      } else {

        String notamServer = PrivateVariables.apiURL;
        String notamApi = "Notam/GetNotam?";
        String notamSource = "source=AppUnknown";
        if (Platform.isAndroid) {
          notamSource = "source=AppAndroid";
        } else if (Platform.isIOS) {
          notamSource = "source=AppIOS";
        } else {
          notamSource = "source=AppOther";
        }
        String notamAirports = "&airports=$allAirports";

        String url = notamServer + notamApi + notamSource + notamAirports;

        String fetchText;
        if (!fetchBoth) {
          fetchText = "Fetching NOTAM, hold position!";
        } else {
          fetchText = "Fetching NOTAM and WEATHER, hold position!";

          if (_myRequestedAirports.length > 6) {
            fetchText += "\n\nToo many NOTAM requested, this might take time! If it fails, "
                "please try with less next time!";
            firstSnackTimeNeeded = 8;
          }
        }
        widget.hideBottomNavBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(fetchText),
            duration: Duration(seconds: firstSnackTimeNeeded),
          ),
        );

        int timeOut = 20 * _myRequestedAirports.length;
        final response = await http.post(url).timeout(Duration(seconds: timeOut));

        if (response.statusCode != 200) {
          notamFailed = true;

        } else {
          notamExportedJson = notamJsonFromJson(response.body);

          var timeNow = DateTime.now().toUtc();
          _requestedTime = timeNow.toIso8601String();

          SharedPreferencesModel().setNotamInformation(response.body);
          SharedPreferencesModel().setNotamUserInput(_userSubmitText);
          SharedPreferencesModel().setNotamRequestedAirports(_myRequestedAirports);
          SharedPreferencesModel().setNotamRequestedTime(_requestedTime);
        }

        if (fetchBoth) {
          String wxServer = PrivateVariables.apiURL;
          String wxApi = "Wx/GetWx?";
          String wxSource = "source=AppUnknown";
          if (Platform.isAndroid) {
            wxSource = "source=AppAndroid";
          } else if (Platform.isIOS) {
            wxSource = "source=AppIOS";
          } else {
            wxSource = "source=AppOther";
          }
          String wxAirports = "&Airports=$allAirports";

          int savedHoursBefore;
          bool mostRecent;

          await SharedPreferencesModel().getWeatherHoursBefore().then((onValue) {
            savedHoursBefore = onValue;
          });

          int internalHoursBefore;
          if (savedHoursBefore == 0) {
            mostRecent = true;
            internalHoursBefore = 10;
          } else {
            mostRecent = false;
            internalHoursBefore = savedHoursBefore;
          }

          String mostRecentString = "&mostRecent=$mostRecent";
          String hoursBefore = "&hoursBefore=$internalHoursBefore";

          String wxUrl = wxServer + wxApi + wxSource + wxAirports + mostRecentString + hoursBefore;

          int timeOut = 20 * _myRequestedAirports.length;
          final response = await http.post(wxUrl).timeout(Duration(seconds: timeOut));

          if (response.statusCode != 200) {
            wxFailed = true;

          } else {
            SharedPreferencesModel().setWeatherInformation(response.body);
            SharedPreferencesModel().setWeatherUserInput(_userSubmitText);
            SharedPreferencesModel().setWeatherRequestedAirports(_myRequestedAirports);
          }

        }

        if (wxFailed || notamFailed) {
          throw "error";
        }

      }

    } catch (Exception) {

      String expString = "";
      if (fetchBoth) {
        if (wxFailed && notamFailed) {
          expString = "Fetching failed both for NOTAM and WX, please try again later!";
        } else if (wxFailed) {
          expString = "NOTAM were proccessed, but fetching failed for WEATHER!";
        } else if (notamFailed) {
          expString = "Fetching failed for NOTAM, but WEATHER was proccessed!";
        } else {
          expString = "There was an error with the server or the Internet connection!";
        }
      } else {
        if (wxFailed) {
          expString = "Failed fetching NOTAM, please try again later!";
        } else {
          expString = "There was an error with the server or the Internet connection!";
        }
      }

      widget.hideBottomNavBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
              expString,
              style: TextStyle(
                color: Colors.black,
              )
          ),
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
        myWait = firstSnackTimeNeeded - diffTime + 7;   // First SnackBar - time until now + time for the second one
      } else {
        myWait = 7;  // If more time has elapsed, just wait 6 + 1 seconds for the error SnackBar
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

    return notamExportedJson;
  }


  Future<void> _showMap({notamId, latitude, longitude, radius}) async {
    LatLng _center = LatLng(latitude, longitude);

    // creating a new MARKER
    var markerIdVal = notamId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(title: notamId, snippet: 'Radius: ${radius.toString()} NM'),
      visible: true,
    );
    List<Marker> markersList = new List<Marker>();
    markersList.add(marker);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
          child: Container(
            padding: EdgeInsets.fromLTRB(15,25,15,15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding:  EdgeInsets.only(bottom: 20),
                    child: Text(
                      'NOTAM $notamId',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded (
                  child: GoogleMap(
                    mapType: MapType.hybrid,
                    onMapCreated: (GoogleMapController controller) {
                      // Not necessary??
                      //_mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 11.0,
                    ),
                    markers: Set<Marker>.of(markersList),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only (top: 20),
                  child: RaisedButton(
                    child: Text(
                      'Roger!',
                      style: TextStyle(
                        fontSize: 18,
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
      },
    );
  }

  Future<void> _showFullNotam(String notamId, String notamText) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5),
          title: Text(notamId),
          content: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              notamText,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Roger!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future _scrollToNotam({@required int position}) async {
    // We need to scroll first quickly pass the target so that
    // the header is shown on the screen (very quick). Otherwise, scrolling
    // directly to "begin" will not be precise.
    await _mainScrollController.scrollToIndex(position + 2,
        duration: Duration(milliseconds: 500),
        preferPosition: AutoScrollPosition.begin);

    // This is the actual item we want
    await _mainScrollController.scrollToIndex(position,
        duration: Duration(seconds: 2),
        preferPosition: AutoScrollPosition.begin);

    _mainScrollController.highlight(position);
  }

  List<SpeedDialChild> _mySpeedDials() {
    List<SpeedDialChild> _myDialsList = List<SpeedDialChild>();

    if (_scrollList.length > 1){
      for (var i = _scrollList.length - 1; i >= 0; i--) {
        SpeedDialChild singleDial = SpeedDialChild(
          child: Icon(Icons.local_airport),
          backgroundColor: Colors.red,
          label: _scrollList[i].toUpperCase(),
          labelStyle: TextStyle(
            color: Colors.black,
          ),
          onTap: () => _scrollToNotam(position: i),
        );
        _myDialsList.add(singleDial);
      }
    }


    SpeedDialChild firstDial = SpeedDialChild(
      child: Icon(Icons.arrow_upward),
      backgroundColor: Colors.green,
      label: 'Top',
      labelStyle: TextStyle(
        color: Colors.black,
      ),
      onTap: () => _mainScrollController.animateTo(0,
          duration: Duration(seconds: 2),
          curve: Curves.ease),
    );
    _myDialsList.add(firstDial);

    return _myDialsList;
  }

  void _updateTimes(){
    //print("UPDATING NOTAM TICKER: ${DateTime.now().toUtc()}");
    if (_myNotamList.isNotEmpty){
      setState(() {
        // This will trigger a refresh of weather times
      });
    }
  }

  String _shareThisNotam(NotamSingle thisNotam, String thisAirportName) {
    String mySharedNotam = "";

    mySharedNotam += "###";
    mySharedNotam += "\n### CAVOKATOR NOTAMS ###";
    mySharedNotam += "\n###";

    mySharedNotam += "\n\n*AIRPORT: $thisAirportName\n";

    mySharedNotam += "\n*NOTAM ID: ${thisNotam.id}\n";

    if (thisNotam.categorySubMain != "") {
    mySharedNotam += "\n*Category: ${thisNotam.categorySubMain}";
    }
    if (thisNotam.categorySubSecondary != "") {
    mySharedNotam += "\n*Subcategory: ${thisNotam.categorySubSecondary}";
    }

    mySharedNotam += "\n\n${thisNotam.freeText}";

    // Time formatting
    var formatter = new DateFormat('yyyy-MMM-dd HH:mm');
    String startTimeFormatted = formatter.format(thisNotam.startTime);
    mySharedNotam += "\n\n*From: $startTimeFormatted";

    String notamEndFormatted;
    if (thisNotam.permanent){
      notamEndFormatted = "PERMANENT";
    } else if (thisNotam.estimated){
      notamEndFormatted = formatter.format(thisNotam.endTime) + " (EST)";
    } else {
      notamEndFormatted = formatter.format(thisNotam.endTime);
    }
    mySharedNotam += "\n*To: $notamEndFormatted";

    if (thisNotam.validTimes != "") {
    mySharedNotam += "\n\n*Validity: ${thisNotam.validTimes}";
    }

    if (thisNotam.bottomLimit != "") {
    mySharedNotam += "\n\n*Bottom limit: ${thisNotam.bottomLimit}";
    }
    if (thisNotam.topLimit != "") {
    mySharedNotam += "\n*Top limit: ${thisNotam.topLimit}";
    }

    mySharedNotam += "\n\n\n\n ### END CAVOKATOR REPORT ###";
    return mySharedNotam;

  }

  void onMainScrolled() {
    widget.notifyScrollPosition(_mainScrollController.offset);
  }

  // END OF CLASS
}