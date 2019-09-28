import 'package:flutter/material.dart';


class ChangeLog extends StatelessWidget {

  final String appVersion;

  ChangeLog({@required this.appVersion});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "NEW CAVOKATOR v$appVersion",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 30, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Text("FEATURES",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.local_airport, size: 20),
                    Padding(padding: EdgeInsets.only(right: 8)),
                    Flexible(
                      child: Text(
                        "Added an option to get both WX and NOTAM information"
                            " at the same time from both sections!",
                        //style: TextStyle(
                        //  fontWeight: FontWeight.bold,
                        //),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.local_airport, size: 20),
                    Padding(padding: EdgeInsets.only(right: 8)),
                    Flexible(
                      child: Text(
                        "Added a bottom bar to quickly move between WX and"
                            " NOTAM sections without using the main the menu!",
                        //style: TextStyle(
                        //  fontWeight: FontWeight.bold,
                        //),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.local_airport, size: 20),
                    Padding(padding: EdgeInsets.only(right: 8)),
                    Flexible(
                      child: Text(
                        "Now the scroll position is recorded when moving between"
                            " the WX and NOTAM sections!",
                        //style: TextStyle(
                        //  fontWeight: FontWeight.bold,
                        //),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 5),
                child: Divider(),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        "WARNING: Cavokator was not certified for in-flight "
                            "use, please do not it for real in-flight operations or "
                            "do so under your own responsability. "
                            "There might be errors and the information shown "
                            "might not be completely up to date. ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: RaisedButton(
                  child: Text(
                    'Great!',
                    style: TextStyle(
                      fontSize: 15,
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
      ),



    );
  }

}