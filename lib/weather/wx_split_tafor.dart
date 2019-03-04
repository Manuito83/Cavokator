import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class SplitTafor{

  String _splitResult;
  get getResult => _splitResult;

  SplitTafor({@required String taforString}){

    //var splitRegex = new RegExp(r"(PROB[0-9]{2} TEMPO)|(TEMPO)|(BECMG)|(FM)[0-9]{6}");
    //Iterable<Match> matches = splitRegex.allMatches(taforString);

    _splitResult = taforString.splitMapJoin(RegExp(r"(PROB[0-9]{2} TEMPO)|(TEMPO)|(BECMG)|(FM)[0-9]{6}", multiLine: true),
      onMatch: (m) => '\n>> ${m.group(0)}',
      onNonMatch: (n) => n);

  }
}