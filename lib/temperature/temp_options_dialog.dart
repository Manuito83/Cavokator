import 'package:flutter/material.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';


class TempOptionsDialog extends StatefulWidget {
  final int round;
  final Function roundChangedCallback;

  TempOptionsDialog({@required this.round,
    @required this.roundChangedCallback});


  @override
  _TempOptionsDialog createState() => _TempOptionsDialog();
}

class _TempOptionsDialog extends State<TempOptionsDialog> {
  int _round;

  @override
  void initState() {
    _round = widget.round;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.fromLTRB(15,25,15,15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "TEMP OPTIONS",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text("Round result?"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                  ),
                  Flexible(
                    child: DropdownButton<String> (
                      value: _round.toString(),
                      items: [
                        DropdownMenuItem(
                          value: "0",
                          child: Text(
                            "No",
                            style: TextStyle (
                              fontSize: 14,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "10",
                          child: Text(
                            "Higher 10ft",
                            style: TextStyle (
                              fontSize: 14,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "50",
                          child: Text(
                            "Higher 50ft",
                            style: TextStyle (
                              fontSize: 14,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "100",
                          child: Text(
                            "Higher 100ft",
                            style: TextStyle (
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        _roundValueChanged(int.parse(value));
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only (top: 30),
              child: RaisedButton(
                child: Text(
                  'Done!',
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
    );
  }

  void _roundValueChanged(int newValue) {
    setState(() {
      _round = newValue;
    });

    widget.roundChangedCallback(newValue);

    SharedPreferencesModel().setTempRound(newValue);
  }

}