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
                      child: Text("NOTICE",
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
                    Icon(Icons.warning, size: 20),
                    Padding(padding: EdgeInsets.only(right: 15)),
                    Flexible(
                      child: Text(
                        "Sadly, Cavokator has lost its NOTAMS section for the foreseeable future.\n\n"
                        "After FAA decided to discontinue AIDAP support in 2021, only costly solutions remain "
                        "which would go against Cavokator's freeware spirit.\n\n"
                        "We have tried to find a free or low cost partner, but didn't find anyone willing to collaborate. "
                        "Hence, until a new NOTAM provider can be found in the future, we have sadly deactivated this section.\n\n"
                        "All other Cavokator sections will continue to be maintained.",
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