import 'dart:convert';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cavokator_flutter/favourites/favourites_backups.dart';
import 'package:cavokator_flutter/json_models/favourites_model.dart';
import 'package:cavokator_flutter/utils/theme_me.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'dart:async';
import 'package:cavokator_flutter/utils/shared_prefs.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


enum FavFrom {
  drawer,
  weather,
  notam,
}

class FavouritesPage extends StatefulWidget {
  final FavFrom favFrom;
  final bool isThemeDark;
  final Function callbackFab;
  final Function callbackFromFav;
  final List<String> importedAirports;
  final Function callbackPage;
  final int maxAirportsRequested;

  FavouritesPage({@required this.isThemeDark, @required this.callbackFab,
                  @required this.callbackFromFav, @required this.favFrom,
                  @required this.importedAirports, @required this.callbackPage,
                  @required this.maxAirportsRequested});

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final _mainFormKey = GlobalKey<FormState>();

  final _titleInputController = new TextEditingController();
  final _airportsInputController = new TextEditingController();
  final _importInputController = new TextEditingController();
  String _userSubmittedAirports = "";

  String _thisInputTitle = "";
  List<String> _thisInputAirportsList = List<String>();

  List<Favourite> _favouritesList = List<Favourite>();

  final _searchController = new TextEditingController();
  String _userSearch = "";

  bool _importing = false;

  // Variables for options dialog
  bool _autoFetch = true;
  bool _fetchBoth = true;


  @override
  void initState() {
    super.initState();

    _restoreSharedPreferences();

    // Delayed callback for FAB
    Future.delayed(Duration.zero, () => fabCallback());

    BackButtonInterceptor.add(myInterceptor);

    _airportsInputController.addListener(onAirportsInputTextChange);
    _searchController.addListener(onSearchInputTextChange);
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
  Future dispose() async {
    _airportsInputController.dispose();
    _titleInputController.dispose();
    _searchController.dispose();
    _importInputController.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  Future<void> fabCallback() async {
    widget.callbackFab(SizedBox.shrink());
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = new List<Widget>();

    slivers.add(_myAppBar());
    slivers.add(_mainBody());

    return slivers;
  }

  Widget _myAppBar() {
    Widget returnArrow;
    if (widget.favFrom == FavFrom.weather) {
      returnArrow = IconButton(
        icon: Icon(Icons.arrow_back),
        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
        onPressed: () {
          widget.callbackPage(0);
        },
      );
    } else if (widget.favFrom == FavFrom.notam) {
      returnArrow = IconButton(
        icon: Icon(Icons.arrow_back),
        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
        onPressed: () {
          widget.callbackPage(1);
        },
      );
    } else {
      returnArrow = SizedBox.shrink();
    }
    return SliverAppBar(
      title: Text("Favourites"),
      pinned: true,
      actions: <Widget>[
        returnArrow,
        IconButton(
          icon: Icon(Icons.delete_forever),
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          onPressed: () {
            _deleteAllFavsDialog();
          },
        ),
        IconButton(
          icon: Icon(Icons.save),
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                FavouritesBackupsPage(
                  isThemeDark: widget.isThemeDark,
                  currentFavList: _favouritesList,
                  updateCallback: _updateFromImport,
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.settings),
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          onPressed: () {
            _settingsDialog();
          },
        ),
      ],
    );
  }

  Widget _mainBody () {
    return CustomSliverSection(
        child: Column (
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding (
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: "Search",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0))),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 5),
              child: _addButtons(),
            ),
            Flexible(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: _favouritesList.length,
                itemBuilder: (context, index) {
                  if (_userSearch == "") {
                    return _favouriteCard(index);
                  } else {
                    if (_favouritesList[index].title.toUpperCase()
                        .contains(_userSearch.toUpperCase())) {
                      return _favouriteCard(index);
                    } else {
                      return SizedBox.shrink();
                    }
                  }
                }
              ),
            ),
            SizedBox(height: 60.0),
          ],
        ),
    );
  }

  Widget _addButtons () {
    if (widget.favFrom == FavFrom.drawer) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ButtonTheme(
            minWidth: 1.0,
            buttonColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.Buttons),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
                side: BorderSide(
                  color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                  ),
                  Text(" Add new"),
                ],
              ),
              onPressed: ()  {
                _thisInputTitle = "";
                _thisInputAirportsList.clear();
                _titleInputController.text = "";
                _airportsInputController.text = "";
                _showAddDialog();
              },
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonTheme(
                minWidth: 1.0,
                buttonColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.Buttons),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MagentaCategory),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      ImageIcon(
                        AssetImage(
                          widget.favFrom == FavFrom.weather
                              ? "assets/icons/drawer_wx.png"
                              : "assets/icons/drawer_notam.png"
                        ),
                        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                      ),
                      Text("  Import"),
                    ],
                  ),
                  onPressed: ()  {
                    _thisInputTitle = "";
                    _thisInputAirportsList.clear();
                    _titleInputController.text = "";
                    _airportsInputController.text = "";
                    _importing = true;
                    _showAddDialog();
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonTheme(
                minWidth: 1.0,
                buttonColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.Buttons),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                      ),
                      Text(" Add new"),
                    ],
                  ),
                  onPressed: ()  {
                    _thisInputTitle = "";
                    _thisInputAirportsList.clear();
                    _titleInputController.text = "";
                    _airportsInputController.text = "";
                    _showAddDialog();
                  },
                ),
              ),
            ],
          )
        ],
      );
    }
  }


  Widget _favouriteCard(int index) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      actions: <Widget>[
        new IconSlideAction(
        caption: 'Edit',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () =>
              _showAddDialog(
                existingFav: true,
                favIndex: index,
                favTitle: _favouritesList[index].title,
                favAirports: _favouritesList[index].airports
              ),
        ),
      ],
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () =>
              _deleteSingleFavDialog(index),
        ),
      ],
      child: Card(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      elevation: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // onTap: // In case we want to do something on card tap
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(25, 20, 15, 0),
                    child: RichText(
                      text: TextSpan(
                        text: _favouritesList[index].title,
                        style: TextStyle(
                            color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25, 5, 15, 20),
                    child: RichText(
                      text: TextSpan(
                        text: _favouritesList[index].airports.join(', '),
                        style: TextStyle(
                            color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 80, child: VerticalDivider(
            color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),),
          ),
          Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.fromLTRB(5, 5, 15, 0),
                      child: IconButton(
                        icon: ImageIcon(
                          AssetImage("assets/icons/drawer_wx.png"),
                          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                        ),
                        onPressed: () {
                          // Call weather
                          List<String> airportsToWx = List<String>();
                          for (var fav in _favouritesList[index].airports) {
                            airportsToWx.add(fav);
                          }
                          widget.callbackFromFav(0, airportsToWx, _autoFetch, _fetchBoth);
                        },
                      )
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 15, 5),
                    child:  IconButton(
                        icon: ImageIcon(
                          AssetImage("assets/icons/drawer_notam.png"),
                          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                        ),
                        onPressed: () {
                          // Call weather
                          List<String> airportsToNotam = List<String>();
                          for (var fav in _favouritesList[index].airports) {
                            airportsToNotam.add(fav);
                          }
                          widget.callbackFromFav(1, airportsToNotam, _autoFetch, _fetchBoth);
                        }
                    ),
                  ),
                ],
              ),

              // This has been removed to facilitate the test of
              // the "Slidable". If things go wrong, two icons are ready here!
              /*
              Container(height: 80, child: VerticalDivider(color: Colors.black)),
              Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 5, 0),
                      child: IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.black45,
                        onPressed: () {
                          _showAddDialog(
                              existingFav: true,
                              favIndex: index,
                              favTitle: _favouritesList[index].title,
                              favAirports: _favouritesList[index].airports
                          );
                        },
                      )
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
                    child:  IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.black45,
                        onPressed: () {
                          _deleteSingleFavDialog(index);
                        }
                    ),
                  ),
                ],
              ),
              */

            ],
          )
        ],
      ),
    ),
    );










  }

  Future<void> _showAddDialog({bool existingFav = false, int favIndex, String favTitle, List<String> favAirports}) async {
    if (existingFav) {
      _titleInputController.text = favTitle;
      _airportsInputController.text = favAirports.join(", ");
    }
    if (_importing // Make sure the "add new" button does not trigger an import
        && widget.favFrom != FavFrom.drawer
        && widget.importedAirports.length > 0) {
      _airportsInputController.text = widget.importedAirports.join(", ");
      _importing = false;
    }
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              content: SingleChildScrollView(
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(
                          top: 45,
                          bottom: 16,
                          left: 16,
                          right: 16,
                        ),
                        margin: EdgeInsets.only(top: 30),
                        decoration: new BoxDecoration(
                          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _mainFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // To make the card compact
                            children: <Widget>[
                              TextFormField(
                                style: TextStyle(
                                    fontSize: 14
                                ),
                                controller: _titleInputController,
                                maxLength: 50,
                                minLines: 1,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: OutlineInputBorder(),
                                  labelText: 'Favourite title',
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Title cannot be empty!";
                                  }
                                  _thisInputTitle = value.trim();
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.0),
                              TextFormField(
                                style: TextStyle(
                                  fontSize: 14
                                ),
                                controller: _airportsInputController,
                                minLines: 1,
                                maxLines: 4,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.characters,
                                decoration: InputDecoration(
                                  errorMaxLines: 3,
                                  border: OutlineInputBorder(),
                                  labelText: 'ICAO/IATA airports',
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please enter at least one valid airport!";
                                  }
                                  // Try to parse some airports
                                  // Split the input to suit or needs
                                  RegExp exp = new RegExp(r"([a-z]|[A-Z]){3,4}");
                                  Iterable<Match> matches = exp.allMatches(_userSubmittedAirports);
                                  matches.forEach((m) => _thisInputAirportsList.add(m.group(0)));
                                  if (_thisInputAirportsList.isEmpty) {
                                    return "Could not identify a valid airport!";
                                  }
                                  if (_thisInputAirportsList.length > widget.maxAirportsRequested) {
                                    _thisInputAirportsList.clear();
                                    return "Too many airports (max is ${widget.maxAirportsRequested})! "
                                        "You can change this in settings.";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      if (_mainFormKey.currentState.validate()) {
                                        if (existingFav) {
                                          _modifyFavourite(favIndex);
                                        } else {
                                          _addNewFavourite();
                                        }
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: existingFav
                                        ? Text("Modify")
                                        : Text("Add"),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 16,
                      right: 16,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                        child: CircleAvatar(
                          backgroundColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                          radius: 22,
                          child: Icon(
                            Icons.favorite_border,
                            color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )


            );
        }
    );
  }

  Future<void> _deleteSingleFavDialog(int removeIndex) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          content: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    top: 42,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  margin: EdgeInsets.only(top: 22),
                  decoration: new BoxDecoration(
                    color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // To make the card compact
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Text(
                            'Are you sure you want to remove "${_favouritesList[removeIndex].title}" '
                                'and all its associated airports? \n\n This cannot be undone!',
                          )
                      ),
                      SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Oh no!"),
                          ),
                          FlatButton(
                            onPressed: () {
                              setState(() {
                                _favouritesList.removeAt(removeIndex);
                              });
                              _saveFavPrefs();
                              Navigator.of(context).pop();
                            },
                            child: Text("Do it!"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                    child: CircleAvatar(
                      backgroundColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                      radius: 22,
                      child: Icon(
                        Icons.warning,
                        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Future<void> _deleteAllFavsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          content: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    top: 42,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  margin: EdgeInsets.only(top: 22),
                  decoration: new BoxDecoration(
                    color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // To make the card compact
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Text(
                              'Are you sure you want to remove ALL your favourites and '
                                  'all associated airports? \n\n This cannot be undone!'
                          )
                      ),
                      SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Oh no!"),
                          ),
                          FlatButton(
                            onPressed: () {
                              setState(() {
                                _favouritesList.clear();
                              });
                              _saveFavPrefs();
                              Navigator.of(context).pop();
                            },
                            child: Text("Do it!"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                    child: CircleAvatar(
                      backgroundColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                      radius: 22,
                      child: Icon(
                        Icons.warning,
                        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Future<void> _settingsDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          top: 42,
                          bottom: 16,
                          left: 16,
                          right: 16,
                        ),
                        margin: EdgeInsets.only(top: 22),
                        decoration: new BoxDecoration(
                          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // To make the card compact
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Text(
                                "OPTIONS",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.only(start: 15, end: 15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Auto fetch after clicking "
                                              "WX or NOTAM",
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.only(start: 5, end: 15,),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Switch(
                                            value: _autoFetch,
                                            onChanged: (bool value) {
                                              setState(() {
                                                _handleAutoFetchChanged(value);
                                                // Fetching both only occurs
                                                // if auto fetch is active
                                                if (value == false) {
                                                  _handleGetBoth(value);
                                                }
                                              });

                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(start: 15, end: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Fetch both WX & NOTAM even if the "
                                            "other is selected",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _autoFetch
                                                ? ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText)
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(start: 5, end: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Switch(
                                          value: _fetchBoth,
                                          onChanged: (bool value) {
                                            setState(() {
                                              // Fetching both only occurs
                                              // if auto fetch is active
                                              if (_autoFetch) {
                                                _handleGetBoth(value);
                                              }
                                            });

                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Close"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                          child: CircleAvatar(
                            backgroundColor: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                            radius: 22,
                            child: Icon(
                              Icons.settings,
                              color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          );
        }
    );
  }

  void _modifyFavourite(int favIndex) {
    var myModifiedFavourite = Favourite(
      title: _thisInputTitle,
      airports: List<String>.from(_thisInputAirportsList.map((x) => x.trim())),
    );
    setState(() {
      _favouritesList[favIndex] = myModifiedFavourite;
      _favouritesList.sort((a, b) => (a.title).compareTo(b.title));
    });

    _saveFavPrefs();

    Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 8),
        content: Text(
          'Updated "$_thisInputTitle" '
              'with the following airports: '
              '${_thisInputAirportsList.join(', ')}',
        ),
      ),
    );

    _thisInputTitle = "";
    _thisInputAirportsList.clear();
  }

  void _addNewFavourite() {
    var myNewFavourite = Favourite(
      title: _thisInputTitle,
      airports: List<String>.from(_thisInputAirportsList.map((x) => x)),
    );
    setState(() {
      _favouritesList.add(myNewFavourite);
      _favouritesList.sort((a, b) => (a.title).compareTo(b.title));
    });

    _saveFavPrefs();

    Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 8),
        content: Text(
          'Added "$_thisInputTitle" to favourites, '
              'with the following airports: '
              '${_thisInputAirportsList.join(', ')}',
        ),
      ),
    );

    _thisInputTitle = "";
    _thisInputAirportsList.clear();
  }

  void _saveFavPrefs() {
    String favouriteToJson = json.encode(List<dynamic>.from(_favouritesList.map((x) => x.toJson())));
    SharedPreferencesModel().setFavourites(favouriteToJson);
  }

  void onAirportsInputTextChange() {
    // Ensure that submitted airports are split correctly
    String textEntered = _airportsInputController.text;
    // Don't do anything if we are deleting text!
    if (textEntered.length > _userSubmittedAirports.length) {
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
          _airportsInputController.value = TextEditingValue(
            text: textEntered + " ",
            selection: TextSelection.fromPosition(
                TextPosition(
                    offset: (textEntered + " ").length)
            ),
          );
        }
      }
    }
    _userSubmittedAirports = textEntered;
  }

  void onSearchInputTextChange() {
    setState(() {
      _userSearch = _searchController.text;
    });
  }

  void _restoreSharedPreferences() async {
    await SharedPreferencesModel().getFavourites().then((onValue) {
      if (onValue != "") {
        _favouritesList = favouriteListFromJson(onValue);
      }
      setState(() { });
    });

    await SharedPreferencesModel().getFavouritesAutoFetch().then((onValue) {
      _autoFetch = onValue;
    });

    await SharedPreferencesModel().getFavouritesFetchBoth().then((onValue) {
      _fetchBoth = onValue;
    });
  }

  void _updateFromImport (List<Favourite> tentativeList, bool overwrite) {
    if (overwrite) {
      setState(() {
        _favouritesList = List<Favourite>.from(tentativeList);
        _favouritesList.sort((a, b) => (a.title).compareTo(b.title));
      });
    } else {
      for (var fav in tentativeList) {
        _favouritesList.add(fav);
        _favouritesList.sort((a, b) => (a.title).compareTo(b.title));
      }
    }
    _saveFavPrefs();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    if (widget.favFrom == FavFrom.weather){
      widget.callbackPage(0);
      return true;
    } else if (widget.favFrom == FavFrom.notam) {
      widget.callbackPage(1);
      return true;
    } else {
      return false;
    }
  }

  void _handleAutoFetchChanged(bool value) {
    _autoFetch = value;
    SharedPreferencesModel().setFavouritesAutoFetch(value);
    if (value == false) {
      SharedPreferencesModel().setFavouritesFetchBoth(value);
    }
  }

  void _handleGetBoth(bool value) {
    _fetchBoth = value;
    SharedPreferencesModel().setFavouritesFetchBoth(value);
  }

}