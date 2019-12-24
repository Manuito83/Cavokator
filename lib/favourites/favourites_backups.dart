import 'dart:async';
import 'dart:convert';
import 'package:cavokator_flutter/json_models/favourites_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class FavouritesBackupsPage extends StatefulWidget {
  final bool isThemeDark;
  final List<Favourite> favouritesList;
  // TODO: pass theme and theme it!

  FavouritesBackupsPage({@required this.isThemeDark, this.favouritesList});

  @override
  _FavouritesBackupsPageState createState() => _FavouritesBackupsPageState();
}

class _FavouritesBackupsPageState extends State<FavouritesBackupsPage> {
  final _importFormKey = GlobalKey<FormState>();
  final _importInputController = new TextEditingController();
  List<Favourite> _favouritesList = List<Favourite>();

  String _exportInfo =
      "In order to export & backup your favourites, you can either copy/paste "
      "to a text file manually, or share and save it at your desired location. "
      "In any case, please keep the text original structure.";


  @override
  void initState() {
    _favouritesList = widget.favouritesList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String status = "";
    Color statusColor = Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: Text("Import & Export"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(15, 30, 20, 15),
              child: Text(
                "HOW TO EXPORT",
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
            Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: RaisedButton.icon(
                  icon: Icon(Icons.content_copy),
                  label: Text("Clipboard"),
                  onPressed: () async {
                    _saveClipboard().then((onValue) {
                      if (onValue == true) {
                        setState(() {
                          status = "Copied to clipboard!";
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
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Divider(),
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
                        hintText: 'Paste here previously exported data',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Cannot be empty!";
                        }
                        _importFromForm();
                        return null;
                      },
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: RaisedButton.icon(
                          icon: Icon(Icons.file_download),
                          label: Text("Import favourites"),
                          onPressed: ()  {
                            if (_importFormKey.currentState.validate()) {
                              _importFromForm().then((onValue) {
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
                            }
                          },
                        )
                    ),
                  ],
                ),
              ),
            ),
            Padding(
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
          ],
        ),
      ),
    );
  }


  @override
  Future dispose() async {
    super.dispose();
  }


  Future<bool> _saveClipboard() async {
    try {
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String favouriteListToJson = encoder.convert((List<dynamic>.from(_favouritesList.map((x) => x.toJson()))));
      ClipboardData jsonFav = ClipboardData(
        text: favouriteListToJson,
      );
      Clipboard.setData(jsonFav);
      return true;
    } catch (e ){
      return false;
    }
  }

  Future<int> _importFromForm() async {
    try {
      String contents = _importInputController.text;
      final favourites = favouriteListFromJson(contents);

      for (var fav in favourites) {
        print(fav.airports);
      }
      // TODO: add to main list!!!!!

      return favourites.length;
    } catch (e) {
      return 0;
    }
  }


}