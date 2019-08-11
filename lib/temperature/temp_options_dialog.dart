import 'package:flutter/material.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';


class TempOptionsDialog extends StatefulWidget {
  final bool round;
  final Function roundChangedCallback;

  TempOptionsDialog({@required this.round,
    @required this.roundChangedCallback});


  @override
  _TempOptionsDialog createState() => _TempOptionsDialog();
}

class _TempOptionsDialog extends State<TempOptionsDialog> {
  bool _round;

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
                    child: Text("Round to the higher 100"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                  ),
                  Flexible(
                    child: Switch(
                      value: _round,
                      onChanged: (bool value) {
                        _roundValueChanged(value);
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

  void _roundValueChanged(bool newValue) {
    setState(() {
      _round = newValue;
    });

    widget.roundChangedCallback(newValue);

    SharedPreferencesModel().setTempRound(newValue);
  }

}