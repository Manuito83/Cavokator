import 'dart:async';
import 'dart:convert';
import 'package:cavokator_flutter/json_models/favourites_model.dart';
import 'package:cavokator_flutter/utils/theme_me.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

class FavouritesBackupsPage extends StatefulWidget {
  final bool isThemeDark;
  final List<Favourite> currentFavList;
  final Function updateCallback;

  FavouritesBackupsPage({@required this.isThemeDark, this.currentFavList,
                        this.updateCallback});

  @override
  _FavouritesBackupsPageState createState() => _FavouritesBackupsPageState();
}

class _FavouritesBackupsPageState extends State<FavouritesBackupsPage> {
  final _importFormKey = GlobalKey<FormState>();
  final _importInputController = new TextEditingController();
  List<Favourite> _currentFavList = List<Favourite>();
  List<Favourite> _tentativeImportList = List<Favourite>();

  String _exportInfo =
      "In order to export & backup your favourites, you can either copy/paste "
      "to a text file manually, or share and save it at your desired location. "
      "In any case, please keep the text original structure.";

  String _importInfo =
      "In order to import favourites, please paste here the string that "
      "you exported in the past. You can make changes outside of Caveokator, "
      "but ensure that the main structure is kept!";

  String _importChoice =
      "you can either add them to your current list, or replace everything "
      "(you'll lose your current favourites!). Choose wisely.";

  Color _importHintStyle = Colors.black;
  String _importHintText = 'Paste here previously exported data';
  FontWeight _importHintWeight = FontWeight.normal;

  @override
  void initState() {
    _importHintStyle = ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText);
    _currentFavList = widget.currentFavList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Import & Export"),
      ),
      body: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 30, 20, 15),
                      child: Text(
                        "HOW TO EXPORT FAVOURITES",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 15),
                      child: Text(
                        _exportInfo,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Wrap (
                      alignment: WrapAlignment.center,
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: RaisedButton.icon(
                            icon: Icon(Icons.share),
                            label: Text("Export"),
                            onPressed: () async {
                              if (_currentFavList.isEmpty) {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 5),
                                    content: Text(
                                      'No favourites to export!',
                                    ),
                                  ),
                                );
                              } else {
                                _exportShare();
                              }
                            },
                          )
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: RaisedButton.icon(
                            icon: Icon(Icons.content_copy),
                            label: Text("Clipboard"),
                            onPressed: () async {
                              if (_currentFavList.isEmpty) {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 5),
                                    content: Text(
                                      'No favourites to export!',
                                    ),
                                  ),
                                );
                              } else {
                                _saveClipboard().then((onValue) {
                                  if (onValue == true) {
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(seconds: 5),
                                        content: Text(
                                          "${_currentFavList.length } "
                                              "favourites copied to clipboard!",
                                        ),
                                      ),
                                    );
                                  } else {
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(seconds: 5),
                                        content: Text(
                                            "Error!"
                                        ),
                                      ),
                                    );
                                  }
                                });
                              }
                            },
                          )
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
                      child: Divider(),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 20, 15),
                      child: Text(
                        "HOW TO IMPORT FAVOURITES",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 15),
                      child: Text(
                        _importInfo,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Form(
                        key: _importFormKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _importInputController,
                              maxLines: 6,
                              style: TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                counterText: "",
                                border: OutlineInputBorder(),
                                hintText: _importHintText,
                                hintStyle: TextStyle (
                                  color: _importHintStyle,
                                  fontWeight: _importHintWeight,
                                ),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Cannot be empty!";
                                }
                                return null;
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: RaisedButton.icon(
                                  icon: Icon(Icons.file_download),
                                  label: Text("Import"),
                                  onPressed: ()  {
                                    if (_importFormKey.currentState.validate()) {
                                    var numberImported = _importChecker();
                                      if (numberImported == 0) {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            duration: Duration(seconds: 5),
                                            content: Text(
                                              'No favourites to import! '
                                              'Is the file structure correct?',
                                            ),
                                          ),
                                        );
                                      } else {
                                        FocusScope.of(context).requestFocus(new FocusNode());
                                        _showImportDialog();
                                      }
                                    }
                                  }
                                )
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            );
          }
      )
    );
  }

  @override
  Future dispose() async {
    super.dispose();
    _importInputController.dispose();
  }

  void _exportShare()  {
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String favouriteListToJson = encoder.convert(
          (List<dynamic>.from(_currentFavList.map((x) => x.toJson()))));
      Share.share(favouriteListToJson);
  }

  Future<bool> _saveClipboard() async {
    try {
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String favouriteListToJson = encoder.convert(
          (List<dynamic>.from(_currentFavList.map((x) => x.toJson()))));
      ClipboardData jsonFav = ClipboardData(
        text: favouriteListToJson,
      );
      Clipboard.setData(jsonFav);
      return true;
    } catch (e) {
      return false;
    }
  }

  int _importChecker() {
    try {
      String contents = _importInputController.text;
      final importedFavourites = favouriteListFromJson(contents);
      _tentativeImportList = importedFavourites;
      return _tentativeImportList.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _showImportDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          content: SingleChildScrollView (
            child: Container(
              padding: EdgeInsets.only(
                top: 12,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              //margin: EdgeInsets.only(top: 30),
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
              child: Column(
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 30, 20, 15),
                    child: Text(
                      "How would you like to import?",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(30, 10, 30, 20),
                    child: Text(
                      "${_tentativeImportList.length} new favourites "
                          "were found, " + _importChoice,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () {
                          widget.updateCallback(_tentativeImportList, false);
                          _importInputController.text = "";
                          setState(() {
                            _importHintText = "Added ${_tentativeImportList.length} "
                                "new favourites to the existing list!";
                            _importHintStyle = Colors.green;
                            _importHintWeight = FontWeight.bold;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text("Add"),
                      ),
                      Padding (
                        padding: const EdgeInsets.only(left: 5, right: 5),
                      ),
                      RaisedButton(
                        onPressed: () {
                          widget.updateCallback(_tentativeImportList, true);
                          _importInputController.clear();
                          setState(() {
                            _importHintText = "Created new list with "
                                "${_tentativeImportList.length} favourites!";
                            _importHintStyle = Colors.green;
                            _importHintWeight = FontWeight.bold;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text("Replace"),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel import"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }


}