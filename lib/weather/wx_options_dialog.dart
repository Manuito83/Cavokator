import 'package:flutter/material.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';


class WeatherOptionsDialog extends StatefulWidget {
  final int hours;
  final Function hoursChangedCallback;

  WeatherOptionsDialog({@required this.hours,
    @required this.hoursChangedCallback});


  @override
  _WeatherOptionsDialog createState() => _WeatherOptionsDialog();
}

class _WeatherOptionsDialog extends State<WeatherOptionsDialog> {
  int _hoursBefore;

  @override
  void initState() {
    _hoursBefore = widget.hours;
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
          children: <Widget>[
            Text(
              "WX OPTIONS",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Padding (
              padding: EdgeInsets.only (top: 40, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text("Fetch previous METAR?"),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only (bottom: 20),
              child: Row(
                  children: <Widget> [
                    Slider(
                      value: _hoursBefore.toDouble(),
                      max: 12,
                      min: 0,
                      divisions: 12,
                      onChanged: (double newValue) => _hoursBeforeChanged(newValue),
                    ),
                    Flexible(
                      child: Text(
                        _hoursBefore == 0
                            ? "Last only"
                            : "Past $_hoursBefore hours",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ]
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

  void _hoursBeforeChanged(double newValue) {
    setState(() {
      _hoursBefore = newValue.toInt();
    });

    widget.hoursChangedCallback(newValue);

    SharedPreferencesModel().setWeatherHoursBefore(newValue.toInt());
  }

}