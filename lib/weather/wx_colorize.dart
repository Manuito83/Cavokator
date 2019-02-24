import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class MetarColorize {

  BuildContext myContext;

  TextSpan _colorizedResult;
  get getResult => _colorizedResult;

  // Wind Intensity
  int _regularWindIntensity = 20;
  int _badWindIntensity = 30;

  // Gust Intensity
  int _regularGustIntensity = 30;
  int _badGustIntensity = 40;

  // Wind Meters Per Second Intensity
  int _regularMpsWindIntensity = 10;
  int _badMpsWindIntensity = 15;

  // Wind Meters Per Second Gust
  int _regularMpsGustIntensity = 15;
  int _badMpsGustIntensity = 20;

  // Visibility
  int _regularVisibility = 6000;
  int _badVisibility = 1000;

  // RVR
  int _regularRvr = 1000;
  int _badRvr = 1500;

  List<String> GoodWeather = [
    "CAVOK",
    "NOSIG",
    "NSC",
    "00000KT"
  ];

  List<String> RegularWeather = [
    "-RA([A-Z]+|\z)?",                // -RA, -RA(whatever), including last word in string
    "RA([A-Z]+|\z)?",                 // RA, RA(whatever), including last word in string

    "SH([A-Z]+|\z)?",                 // SH, SH(whatever), including last word in string
    "-SH([A-Z]+|\z)?",                // -SH, -SH(whatever), including last word in string

    "-TS([A-Z]+|\z)?",                // -TS, -TS(whatever), including last word in string
    "TS([A-Z]+|\z)?",                 // TS, TS(whatever), including last word in string

    "-FZ([A-Z]+|\z)?",                // -FZ, -FZ(whatever), including last word in string

    "-RA", "RA",                      // Rain
    "-DZ", "DZ",                      // Drizzle
    "-SG", "SG",                      // Snow Grains
    "IC",                                // Ice Crystals
    "-PE", "PE",                      // Ice Pellets

    "OVC003", "OVC004",                   // Cloud cover
    "BKN003", "BKN004",

    "-SN", "DRSN", "DRSN",               // Snow

    "-GR", "GR",                      // Hail
    "-GS", "GS",                      // Small Hail

    "BR+", "FU+",       // Visibility
    "DU+", "SA+",       // Visibility
    "HZ+", "PY+",       // Visibility
    "VCFG", "MIFG", "PRFG", "BCFG",
    "DRDU", "BLDU", "DRSA", "BLSA", "BLPY",

    "RERA", "VCSH", "VCTS", "SHRA"          // Some others
  ];


  List<String> BadWeather = [
    "\s[+](([A-Z]+)|(\z))",                // ANYTHING WITH A "+"
    "[+]TS(([A-Z]+)|(\z))",                // +TS, +TS(whatever), including last word in string
    "[+]SH(([A-Z]+)|(\z))",                // +SH, +SH(whatever), including last word in string
    "[+]FZ(([A-Z]+)|(\z))",                // +FZ, +FZ(whatever), including last word in string
    "\sFZ(([A-Z]+)|(\z))",                 // FZ, FZ(whatever), including last word in string

    "[+]RA",                               // Rain
    "[+]DZ",                               // Drizzle
    "[+]SG",                               // Snow Grains
    "[+]PE",                               // Ice Pellets
    "\sSN", "[+]SN", "BLSN",               // Snow

    "SHSN", "SHPE", "SHGR", "SHGS",        // Red Showers

    "\sFG", "\sVA+(\s|\b)",                // Visibility

    "OVC001", "OVC002",                    // Cloud cover
    "BKN001", "BKN002",

    "\sPO", "\sSQ", "\sFC", "\sSS",        // Sand/Dust Whirls, Squalls, Funnel Cloud, Sandstorm
    "\sDS+(\s|\z)",                        // Trying to avoid american "distant" (DSNT)
    "[+]FC","[+]SS","[+]DS",
    "\sVCPO", "\sVCSS", "\sVCDS",

    "\sSNOCLO+(\s|\b)"                     // SNOW CLOSED... should be triggered by runway condition
                                           // assessment as in R/SNOCLO//... but just in case
  ];


  MetarColorize ({@required String metar, @required BuildContext context}) {

    myContext = context;
    List<TextSpan> spanList = List<TextSpan>();
    var splittedMetar = metar.split(" ");
    TextSpan thisSpan;

    for (var word in splittedMetar){
      bool found = false;

      // CONDITION
      var conditionRegex = new RegExp(r"((\b)(R)+(\d\d([LCR]?)+(\/)+([0-9]|\/){6})(\b))|((\b)(([0-9]|\/){8})+(\b))|((\b)+(R\/SNOCLO)+(\b))|((\b)+(R\d\d([LCR]?))+(\/)+(CLRD)+(\/\/))");
      if (conditionRegex.hasMatch(word)){
        thisSpan = TextSpan(
          text: word + " ",
          style: TextStyle(color: Colors.orange),
          recognizer: TapGestureRecognizer()..onTap = () {
            _conditionDialog();
          }
        );
        spanList.add(thisSpan);
        continue;
      }

      // GOOD WEATHER
      for (var goodWx in GoodWeather) {
        if (word.contains(goodWx)) {
          thisSpan = TextSpan(
            text: word + " ",
            style: TextStyle(color: Colors.green),
          );
          spanList.add(thisSpan);
          break;
        }
      }

      // REGULAR WEATHER  //TODO: CHECK REGULAR REGEX!!!!!
      String regularString = RegularWeather.join("|");
      var regularRegex = new RegExp(regularString);
      if (regularRegex.hasMatch(word)){
        thisSpan = TextSpan(
            text: word + " ",
            style: TextStyle(color: Colors.orange),
        );
        spanList.add(thisSpan);
        continue;
      }


      /*
      // BAD WEATHER
      for (var badWx in BadWeather) {
        if (word.contains(badWx)) {
          thisSpan = TextSpan(
            text: word + " ",
            style: TextStyle(color: Colors.red),
          );
          spanList.add(thisSpan);
          break;
        }
      }
      */

      // STANDARD (NOTHING FOUND)
      thisSpan = TextSpan(
        text: word + " ",  // TODO: what happens if underline? Probably add more spans just for spaces
        style: TextStyle(color: Colors.black),
      );
      spanList.add(thisSpan);
    }

    _colorizedResult = TextSpan (
      children: spanList,
    );
  }


  Future<void> _conditionDialog() async {
    return showDialog<void>(
      context: myContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rewind and remember'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You will never be satisfied.'),
                Text('You\’re like me. I’m never satisfied.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Regret'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}