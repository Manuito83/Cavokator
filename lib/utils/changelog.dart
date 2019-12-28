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
                    Icon(Icons.favorite, size: 20),
                    Padding(padding: EdgeInsets.only(right: 15)),
                    Flexible(
                      child: Text(
                        "Added a favourites module, so that you can group "
                            "your airports by destination, alternates, etc. "
                            "You can also export them as a backup and import your "
                            "list (or a friend's) at a later stage!",
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