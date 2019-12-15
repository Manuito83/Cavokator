import 'package:cavokator_flutter/json_models/favourites_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'dart:async';
import 'package:cavokator_flutter/utils/shared_prefs.dart';

class FavouritesPage extends StatefulWidget {
  final bool isThemeDark;
  final Widget myFloat;
  final Function callback;

  FavouritesPage({@required this.isThemeDark, @required this.myFloat,
                @required this.callback});

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final _formKey = GlobalKey<FormState>();
  final _airportsInputController = new TextEditingController();
  String _userSubmittedAirports = "";

  String _favouriteTitle = "";
  List<String> _favouriteAirportsList = List<String>();

  List<Favourite> _favouritesList = List<Favourite>();

  @override
  void initState() {
    super.initState();

    _restoreSharedPreferences();

    // Delayed callback for FAB
    Future.delayed(Duration.zero, () => fabCallback());

    _airportsInputController.addListener(onAirportsInputTextChange);
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
    );
  }

  Widget _mainBody () {
    return CustomSliverSection(
      child: Container (
        child: Column (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding (
              padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text (
                      "SEARCH BAR",
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RawMaterialButton (
                    shape: new CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.grey,
                    child: Icon(Icons.add),
                    onPressed: () {
                      _favouriteTitle = "";
                      _favouriteAirportsList.clear();
                      _airportsInputController.text = "";
                      _showAddDialog();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _showAddDialog() async {
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
                        TextFormField(
                          maxLength: 50,
                          maxLines: null,
                          decoration: InputDecoration(
                            counterText: "",
                            border: OutlineInputBorder(),
                            labelText: 'Favourite title',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Title cannot be empty!";
                            }
                            _favouriteTitle = value;
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _airportsInputController,
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
                            matches.forEach((m) => _favouriteAirportsList.add(m.group(0)));
                            if (_favouriteAirportsList.isEmpty) {
                              return "Could not identify a valid airport!";
                            }
                            if (_favouriteAirportsList.length > 10) {
                              // TODO: limit this with option and warning?
                              return "Too many airports (max is 10)!";
                            }
                            return null;
                          },
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
                                  _addNewFavourite();
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text("Add"),
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


  void _addNewFavourite() {
    var myNewFavourite = Favourite(
      title: _favouriteTitle,
      airports: List<String>.from(_favouriteAirportsList.map((x) => x)),
    );
    _favouritesList.add(myNewFavourite);

    Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 8),
        content: Text(
          'Added "$_favouriteTitle" to favourites, '
              'with the following airports: '
              '${_favouriteAirportsList.join(', ')}',
        ),
      ),
    );
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


  void _restoreSharedPreferences() async {
    await SharedPreferencesModel().getSettingsOpenSpecificSection().then((onValue) {
      setState(() {
        // TODO
      });
    });

  }

}