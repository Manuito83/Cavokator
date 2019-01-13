import 'package:flutter/foundation.dart';

class PrettyDuration {

  List<int> _durationList = [0, 0, 0]; // [days], [hours], [minutes]
  String _prettyDuration;
  String _header;

  get getDuration => _prettyDuration;
  get getDurationInMinutes => _durationList[1];

  /// [header] is expected to be something like "METAR" or "TAFOR".
  PrettyDuration({ @required Duration duration, @required String header}) {
    _header = header;
    _calculateDuration(duration);
    _prettyDuration = _buildPrettyDuration();
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
  }

  String _buildPrettyDuration () {
    String myResult = _header + " @ ";
    String finish = " ago";

    if (_durationList[0] > 1 && _durationList[1] > 1)
    {
      myResult += "${_durationList[0]} days, ${_durationList[1]} hours $finish";
    }
    else if (_durationList[0] == 1 && _durationList[1] > 1)
    {
      myResult += "{_durationList[0]} day, ${_durationList[1]} hours $finish";
    }
    else if (_durationList[0] > 1 && _durationList[1] == 1)
    {
      myResult += "{_durationList[0]} days, ${_durationList[1]} hour $finish";
    }
    else if (_durationList[0] == 1 && _durationList[1] == 1)
    {
      myResult += "{_durationList[0]} day, ${_durationList[1]} hour $finish";
    }
    else if (_durationList[0] < 1 && _durationList[1] > 1 && _durationList[2] > 1)
    {
      myResult += "{_durationList[1]} hours, ${_durationList[2]} minutes $finish";
    }
    else if (_durationList[0] < 1 && _durationList[1] == 1 && _durationList[2] > 1)
    {
      myResult += "{_durationList[1]} hour, ${_durationList[2]} minutes $finish";
    }
    else if (_durationList[0] < 1 && _durationList[1] > 1 && _durationList[2] == 1)
    {
      myResult += "{_durationList[1]} hours, ${_durationList[2]} minute $finish";
    }
    else if (_durationList[0] < 1 && _durationList[1] == 1 && _durationList[2] == 1)
    {
      myResult += "{_durationList[1]} hour, ${_durationList[2]} minute $finish";
    }
    else if (_durationList[0] < 1 && _durationList[1] < 1 && _durationList[2] > 1)
    {
      myResult += "${_durationList[2]} minutes $finish";
    }
    else
    {
      myResult += "just now";
    }

    return myResult;
  }

}