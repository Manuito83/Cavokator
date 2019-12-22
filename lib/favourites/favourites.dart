import 'dart:convert';
import 'dart:io';

import 'package:cavokator_flutter/json_models/favourites_model.dart';
import 'package:cavokator_flutter/utils/theme_me.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'dart:async';
import 'package:cavokator_flutter/utils/shared_prefs.dart';
import 'package:path_provider/path_provider.dart';

class FavouritesPage extends StatefulWidget {
  final bool isThemeDark;
  final Widget myFloat;
  final Function callback;
  // TODO: pass theme and theme it!

  FavouritesPage({@required this.isThemeDark, @required this.myFloat,
                @required this.callback});

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleInputController = new TextEditingController();
  final _airportsInputController = new TextEditingController();
  String _userSubmittedAirports = "";

  String _thisInputTitle = "";
  List<String> _thisInputAirportsList = List<String>();

  List<Favourite> _favouritesList = List<Favourite>();

  final _searchController = new TextEditingController();
  String _userSearch = "";


  @override
  void initState() {
    super.initState();

    _restoreSharedPreferences();

    // Delayed callback for FAB
    Future.delayed(Duration.zero, () => fabCallback());

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
    // TODO: ??? >>> _mainScrollController.dispose();
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
      title: Text("Favourites"),
      pinned: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.save),
          color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
          onPressed: () {
            _loadSaveDialog();
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
                        onChanged: (value) {

                        },
                        controller: _searchController,
                        decoration: InputDecoration(
                            labelText: "Search",
                            //hintText: "Search by title",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12.0)))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RawMaterialButton (
                    shape: new CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.grey,
                    child: Icon(Icons.add),
                    onPressed: () {
                      _thisInputTitle = "";
                      _thisInputAirportsList.clear();
                      _titleInputController.text = "";
                      _airportsInputController.text = "";
                      _showAddDialog();
                    },
                  ),
                ],
              ),
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
                    if (_favouritesList[index].title.contains(_userSearch)) {  // TODO: añadir "toUpper" para pillarlo todo
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


  Widget _favouriteCard(int index) {
    return Card(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      elevation: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(25, 20, 15, 0),
                      child: RichText(
                        text: TextSpan(
                          text: _favouritesList[index].title,
                          style: TextStyle(
                              color: Colors.black,
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
                              color: Colors.black
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
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
                padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
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
        ],
      ),
    );
  }


  Future<void> _showAddDialog({bool existingFav = false, int favIndex, String favTitle, List<String> favAirports}) async {
    if (existingFav) {
      _titleInputController.text = favTitle;
      _airportsInputController.text = favAirports.join(", ");
    }
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    top: 82,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  margin: EdgeInsets.only(top: 30),
                  decoration: new BoxDecoration(
                    color: Colors.white,
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
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // To make the card compact
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
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
                              _thisInputTitle = value;
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Flexible(
                          child: TextFormField(
                            controller: _airportsInputController,
                            minLines: 1,
                            maxLines: 4,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
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
                              if (_thisInputAirportsList.length > 10) {
                                // TODO: limit this with option and warning?
                                _thisInputAirportsList.clear();
                                return "Too many airports (max is 10)!";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 24.0),
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
                                if (_formKey.currentState.validate()) {
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
                Positioned(
                  left: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[400],
                    radius: 30,
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.red[800],
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }


  Future<void> _deleteSingleFavDialog(int removeIndex) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
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
                    color: Colors.white,
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
                              'and all its associated airports? \n\n This cannot be undone!'
                        ) // TODO: Probar texto corto en tablet, quizá Stack en Center??
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
                    backgroundColor: Colors.grey[400],
                    radius: 22,
                    child: Icon(
                      Icons.warning,
                      color: Colors.red[800],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }


  Future<void> _loadSaveDialog() async {
    final file = await _localFile;
    return showDialog<void>(
        context: context,
        //barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          String status = "";
          Color statusColor = Colors.black;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Center(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        //alignment: Alignment.center,
                        padding: EdgeInsets.only(
                          top: 42,
                          bottom: 16,
                          left: 16,
                          right: 16,
                        ),
                        margin: EdgeInsets.only(top: 22),
                        decoration: new BoxDecoration(
                          color: Colors.white,
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
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // To make the card compact
                            children: <Widget>[
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                                  child: Text(
                                    "Export and imports file: ${file.path}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: RaisedButton.icon(
                                    icon: Icon(Icons.file_upload),
                                    label: Text("Export favourites"),
                                    onPressed: ()  {
                                      _saveJsonFile(file).then((onValue) {
                                        if (onValue == true) {
                                          setState(() {
                                            status = "File saved!";
                                            statusColor = Colors.green;
                                          });
                                        } else {
                                          setState(() {
                                            status = "Error saving!";
                                            statusColor = Colors.red;
                                          });
                                        }
                                      });
                                    },
                                  )
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: RaisedButton.icon(
                                    icon: Icon(Icons.file_download),
                                    label: Text("Import favourites"),
                                    onPressed: ()  {
                                      _loadJsonFile(file).then((onValue) {
                                        if (onValue > 0) {
                                          setState(() {
                                            status = "$onValue favourites imported!";
                                            statusColor = Colors.green;
                                          });
                                        } else {
                                          setState(() {
                                            status = "Error importing! "
                                                "Did you place the "
                                                "file in the right place?";
                                            statusColor = Colors.red;
                                          });
                                        }
                                      });
                                    },
                                  )
                              ),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                                child: FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Close"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[400],
                          radius: 22,
                          child: Icon(
                            Icons.save,
                            color: Colors.red[800],
                            size: 20,
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
      airports: List<String>.from(_thisInputAirportsList.map((x) => x)),
    );
    setState(() {
      _favouritesList[favIndex] = myModifiedFavourite;
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
      print(_userSearch);
    });
  }


  void _restoreSharedPreferences() async {
    await SharedPreferencesModel().getFavourites().then((onValue) {
      _favouritesList = favouriteListFromJson(onValue);
      setState(() { });
    });
  }


  Future<bool> _saveJsonFile(File file) async {
    try {
      //file.writeAsString(jsonEncode(_favouritesList));

      String favouriteListToJson = json.encode(List<dynamic>.from(_favouritesList.map((x) => x.toJson())));
      file.writeAsString(favouriteListToJson);
      return true;
    } catch (e ){
      return false;
    }
  }

  Future<int> _loadJsonFile(File file) async {
    try {
      final file = await _localFile;
      var contents = await file.readAsString();


      final favourites = favouriteListFromJson(contents);
      // TODO: add to main list!!!!!

      return favourites.length;
    } catch (e) {
      return 0;
    }
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/cavokatorFavs.json');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }



}