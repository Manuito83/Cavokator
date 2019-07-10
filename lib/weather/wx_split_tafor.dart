import 'package:flutter/material.dart';

class SplitTafor{

  List<String> _splitResult = List<String>();
  get getResult => _splitResult;

  SplitTafor({@required String taforString}){

    var newString = taforString.splitMapJoin(RegExp(r"(PROB[0-9]{2} TEMPO)|(TEMPO)|(BECMG)|(FM)[0-9]{6}", multiLine: true),
      onMatch: (m) => '\n>>${m.group(0)}[/trend]',
      onNonMatch: (n) => n);

    var listOfTrends = newString.split("\n>>");

    for (var trend in listOfTrends){
      _splitResult.add(trend);
    }
  }
}