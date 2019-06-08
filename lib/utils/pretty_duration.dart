import 'package:flutter/material.dart';

class PrettyTimeCombination {
  String prettyDuration;
  MaterialColor prettyColor;
  DateTime referenceTime;
}


class PrettyDuration {

  List<int> _durationList = [0, 0, 0, 0]; // [days],[hours],[minutes],[seconds]
  PrettyTimeCombination _prettyTime;
  String _header;
  int _totalHours;
  String _type;

  get getDuration => _prettyTime;
  //get getDurationInMinutes => _durationList[1];  // TODO: delete? useless

  /// [header] is expected to be something like "METAR" or "TAFOR".
  /// [type] determines the color (different depending on what it is)
  PrettyDuration({ @required DateTime referenceTime, @required String header,
                   @required String type}) {
    _header = header;
    _type = type;
    var timeNow = DateTime.now().toUtc();  // TODO: CHANGE WHEN TESTS PERFORMED
    var duration = timeNow.difference(referenceTime);
    _totalHours = duration.inHours;
    _calculateDuration(duration);
    _prettyTime = _buildPrettyDuration();
    _prettyTime.referenceTime = referenceTime;
  }

  void _calculateDuration(Duration duration) {
    if (duration.inDays > 0) {
      _durationList[0] = duration.inDays;
    }

    final int hours = duration.inHours % 24;
    if (hours > 0) {
      _durationList[1] = hours;
    }

    
    final int minutes = duration.inMinutes % 60;
    if (minutes > 0) {
      _durationList[2] = minutes;
    }

    final int seconds = duration.inSeconds % 60;
    if (seconds > 0) {
      _durationList[3] = seconds;
    }

  }

  PrettyTimeCombination _buildPrettyDuration () {
    String myResult = _header + " @ ";
    String finish = "ago";

    if (_durationList[0] > 1 && _durationList[1] > 1)
    {
      myResult += "${_durationList[0]} days, ${_durationList[1]} hours $finish";
    }
    else if (_durationList[0] == 1 && _durationList[1] > 1)
    {
      myResult += "${_durationList[0]} day, ${_durationList[1]} hours $finish";
    }
    else if (_durationList[0] > 1 && _durationList[1] == 1)
    {
      myResult += "${_durationList[0]} days, ${_durationList[1]} hour $finish";
    }
    else if (_durationList[0] == 1 && _durationList[1] == 1)
    {
      myResult += "${_durationList[0]} day, ${_durationList[1]} hour $finish";
    }
    else if (_durationList[0] < 1 && _durationList[1] > 1 && _durationList[2] > 1)
    {
      myResult += "${_durationList[1]} hours, ${_durationList[2]} minutes $finish";
    }
    else if (_durationList[0] < 1 && _durationList[1] == 1 && _durationList[2] > 1)
    {
      myResult += "${_durationList[1]} hour, ${_durationList[2]} minutes $finish";
    }
    else if (_durationList[0] < 1 && _durationList[1] > 1 && _durationList[2] == 1)
    {
      myResult += "${_durationList[1]} hours, ${_durationList[2]} minute $finish";
    }
    else if (_durationList[0] < 1 && _durationList[1] == 1 && _durationList[2] == 1)
    {
      myResult += "${_durationList[1]} hour, ${_durationList[2]} minute $finish";
    }
    else if (_durationList[0] < 1 && _durationList[1] < 1 && _durationList[2] > 1)
    {
      myResult += "${_durationList[2]} minutes $finish";
    }
    else
    {
      myResult += "just now";
    }

    PrettyTimeCombination myTextAndColor = PrettyTimeCombination();
    myTextAndColor.prettyDuration = myResult;

    if (_type == "WEATHER") {
      if (_totalHours < 2){
        myTextAndColor.prettyColor = Colors.green;
      }
      else if (_totalHours >= 2 && _totalHours < 6){
        myTextAndColor.prettyColor = Colors.orange;
      }
      else {
        myTextAndColor.prettyColor = Colors.red;
      }
    } else if (_type == "NOTAM"){
      if (_totalHours < 6){
        myTextAndColor.prettyColor = Colors.green;
      }
      else if (_totalHours >= 6 && _totalHours < 12){
        myTextAndColor.prettyColor = Colors.orange;
      }
      else {
        myTextAndColor.prettyColor = Colors.red;
      }
    }




    return myTextAndColor;
  }

}