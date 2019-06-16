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
    r"CAVOK",
    r"NOSIG",
    r"NSC",
    r"00000KT"
  ];

  List<String> RegularWeather = [
    r"(VC)([A-Z]+)",
    r"^(?!\+)(SH|-SH)([A-Z]+)?",
    r"^(?!\+)(MI|-MI)([A-Z]+)?",
    r"^(?!\+)(BC|-BC)([A-Z]+)?",
    r"^(?!\+)(PR|-PR)([A-Z]+)?",
    r"^(?!\+)(DR|-DR)([A-Z]+)?",
    r"^(?!\+)(BL|-BL)([A-Z]+)?",
    r"^(?!\+)(TS|-TS)([A-Z]+)?",
    r"^(?!\+)(FZ|-FZ)([A-Z]+)?",
    r"^(?!\+)(DZ|-DZ)([A-Z]+)?",
    r"^(?!\+)(RA|-RA)([A-Z]+)?",
    r"^(?!\+)(SN|-SN)([A-Z]+)?",
    r"^(?!\+)(SG|-SG)([A-Z]+)?",
    r"^(?!\+)(PL|-PL)([A-Z]+)?",
    r"^(?!\+)(GR|-GR)([A-Z]+)?",
    r"^(?!\+)(GS|-GS)([A-Z]+)?",
    r"^(?!\+)(UP|-UP)([A-Z]+)?",
    r"^(?!\+)(SG|-SG)([A-Z]+)?",
    r"^(?!\+)(BR|-BR)([A-Z]+)?",
    r"^(?!\+)(FG|-FG)([A-Z]+)?",
    r"^(?!\+)(FU|-FU)([A-Z]+)?",
    r"^(?!\+)(VA|-VA)([A-Z]+)?",
    r"^(?!\+)(DU|-DU)([A-Z]+)?",
    r"^(?!\+)(SA|-SA)([A-Z]+)?",
    r"^(?!\+)(HZ|-HZ)([A-Z]+)?",
    r"^(?!\+)(PO|-PO)([A-Z]+)?",
    r"^(?!\+)(SQ|-SQ)([A-Z]+)?",
    r"^(?!\+)(FC|-FC)([A-Z]+)?",
    r"^(?!\+)(SS|-SS)([A-Z]+)?",
    r"^(?!\+)(DS|-DS)([A-Z]+)?",
    r"OVC003",
    r"OVC004",
    r"OVC005",
    r"OVC006",
    r"OVC007",
    r"OVC008",
    r"BKN003",
    r"BKN004",
    r"BKN005",
    r"BKN006",
    r"BKN007",
    r"BKN008",
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
    var splitMetar = metar.split(" ");
    TextSpan thisSpan;

    for (var word in splitMetar){

      // CONDITION
      var conditionRegex = new RegExp(
          r"((\b)(R)+(\d\d([LCR]?)+(\/)+([0-9]|\/){6})(\b))"
          r"|((\b)(([0-9]|\/){8})+(\b))"
          r"|((\b)+(R\/SNOCLO)+(\b))"
          r"|((\b)+(R\d\d([LCR]?))+(\/)+(CLRD)+(\/\/))");
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
      String goodString = GoodWeather.join("|");
      var goodRegex = new RegExp(goodString);
      if (goodRegex.hasMatch(word)){
        thisSpan = TextSpan(
          text: word + " ",
          style: TextStyle(color: Colors.green),
        );
        spanList.add(thisSpan);
        continue;
      }


      // REGULAR WEATHER
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
      // BAD WEATHER // TODO: Implement this
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