import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cavokator_flutter/condition/condition_decode.dart';

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
  int _regularVisibility = 4000;
  int _badVisibility = 800;

  // RVR
  int _regularRvr = 1000;
  int _badRvr = 600;

  List<String> goodWeather = [
    r"CAVOK",
    r"NOSIG",
    r"NSC",
    r"00000KT",
    r"9999"
  ];

  List<String> regularWeather = [
    r"(VC)(?!PO|DS|SS)([A-Z]+)",
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


  List<String> badWeather = [
    r"^(\+)([A-Z]+)?",               // ANYTHING WITH A "+"
    r"BLSN",
    r"OVC001", "OVC002",             // Cloud cover
    r"BKN001", "BKN002",
    r"(?<!TEM)(\+)?(PO)",
    r"(\+)?(SQ)",
    r"(\+)?(FC)",
    r"(\+)?(SS)",
    r"(\+)?(\-)?(DS)(?![DSNT])",     // Trying to avoid american "distant" (DSNT)
    r"VCPO", r"VCSS", r"VCDS",
  ];


  MetarColorize ({@required String metar, @required BuildContext context}) {

    myContext = context;
    List<TextSpan> spanList = List<TextSpan>();
    var splitMetar = metar.split(" ");
    TextSpan thisSpan;

    for (int i = 0; i < splitMetar.length; i++){

      String currentWord = splitMetar[i];

      // CONDITION
      var conditionRegex = new RegExp(
          r"((\b)(R)+(\d\d([LCR]?)+(\/)+([0-9]|\/){6})(\b))"
          r"|((\b)(([0-9]|\/){8})+(\b))"
          r"|((\b)+(R\/SNOCLO)+(\b))"
          r"|((\b)+(R\d\d([LCR]?))+(\/)+(CLRD)+(\/\/))");
      var conditionRegexSevere = new RegExp(
          r"((\b)+(R\/SNOCLO)+(\b))");
      if (conditionRegex.hasMatch(currentWord)){
        thisSpan = TextSpan(
          text: currentWord,
          style: TextStyle(
            color: conditionRegexSevere.hasMatch(currentWord)
                ? Colors.red : Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()..onTap = () {
            _conditionDialog(currentWord);
          }
        );
        var spanSpace = TextSpan(
          text: " ",
        );
        spanList.add(thisSpan);
        spanList.add(spanSpace);
        continue;
      }

      // GOOD WEATHER
      String goodString = goodWeather.join("|");
      var goodRegex = new RegExp(goodString);
      if (goodRegex.hasMatch(currentWord)){
        thisSpan = TextSpan(
          text: currentWord + " ",
          style: TextStyle(color: Colors.green),
        );
        spanList.add(thisSpan);
        continue;
      }



      // REGULAR WEATHER
      String regularString = regularWeather.join("|");
      var regularRegex = new RegExp(regularString);
      if (regularRegex.hasMatch(currentWord)){
        thisSpan = TextSpan(
            text: currentWord + " ",
            style: TextStyle(color: Colors.orange),
        );
        spanList.add(thisSpan);
        continue;
      }

      // BAD WEATHER
      String badString = badWeather.join("|");
      var badRegex = new RegExp(badString);
      if (badRegex.hasMatch(currentWord)){
        thisSpan = TextSpan(
          text: currentWord + " ",
          style: TextStyle(color: Colors.red),
        );
        spanList.add(thisSpan);
        continue;
      }

      // WIND KNOTS - e.g.: 25015KT
      var windRegex = new RegExp(
          r"\b[0-9]+KT");
      if (windRegex.hasMatch(currentWord)){
        Color thisColor = Colors.black;
        try {
          int knots = int.tryParse(currentWord.substring(3,5));
          if (knots >= _regularWindIntensity && knots <= _badWindIntensity) {
            thisColor = Colors.orange;
          } else if (knots > _badWindIntensity) {
            thisColor = Colors.red;
          }
          thisSpan = TextSpan(
              text: currentWord + " ",
              style: TextStyle(color: thisColor));
        } catch (Exception) {
          thisSpan = TextSpan (
            text: currentWord + " ",
            style: TextStyle(color: thisColor),
          );
        }
        spanList.add(thisSpan);
        continue;
      }

      // WIND KNOTS 2 - e.g.: 25015G34KT
      var wind2Regex = new RegExp(
          r"[0-9]+G[0-9]+KT");
      if (wind2Regex.hasMatch(currentWord)){
        Color thisColor = Colors.black;
        try {
          int knots = int.tryParse(currentWord.substring(3,5));
          int gust = int.tryParse(currentWord.substring(6,8));
          if ((knots >= _regularWindIntensity || gust >= _regularGustIntensity)
              && knots <= _badWindIntensity && gust <= _badGustIntensity) {
            thisColor = Colors.orange;
          } else if (knots > _badWindIntensity || gust > _badGustIntensity) {
            thisColor = Colors.red;
          }
          thisSpan = TextSpan(
              text: currentWord + " ",
              style: TextStyle(color: thisColor));
        } catch (Exception) {
          thisSpan = TextSpan (
            text: currentWord + " ",
            style: TextStyle(color: thisColor),
          );
        }
        spanList.add(thisSpan);
        continue;
      }

      // WIND MPS - e.g.: 25015MPS
      var windRegexMps = new RegExp(
          r"\b[0-9]+MPS");
      if (windRegexMps.hasMatch(currentWord)){
        Color thisColor = Colors.black;
        try {
          int mps = int.tryParse(currentWord.substring(3,5));
          if (mps >= _regularMpsWindIntensity && mps <= _badMpsWindIntensity) {
            thisColor = Colors.orange;
          } else if (mps > _badMpsWindIntensity) {
            thisColor = Colors.red;
          }
          thisSpan = TextSpan(
              text: currentWord + " ",
              style: TextStyle(color: thisColor));
        } catch (Exception) {
          thisSpan = TextSpan (
            text: currentWord + " ",
            style: TextStyle(color: thisColor),
          );
        }
        spanList.add(thisSpan);
        continue;
      }

      // WIND MPS 2 - e.g.: 25015G34MPS
      var wind2RegexMps = new RegExp(
          r"[0-9]+G[0-9]+MPS");
      if (wind2RegexMps.hasMatch(currentWord)){
        Color thisColor = Colors.black;
        try {
          int mps = int.tryParse(currentWord.substring(3,5));
          int gust = int.tryParse(currentWord.substring(6,8));
          if ((mps >= _regularMpsWindIntensity || gust >= _regularMpsGustIntensity)
              && mps <= _badMpsWindIntensity && gust <= _badMpsGustIntensity) {
            thisColor = Colors.orange;
          } else if (mps > _badMpsWindIntensity || gust > _badMpsGustIntensity) {
            thisColor = Colors.red;
          }
          thisSpan = TextSpan(
              text: currentWord + " ",
              style: TextStyle(color: thisColor));
        } catch (Exception) {
          thisSpan = TextSpan (
            text: currentWord + " ",
            style: TextStyle(color: thisColor),
          );
        }
        spanList.add(thisSpan);
        continue;
      }


      // VISIBILITY
      // Need to get exclude all / before and after, otherwise some parts
      // won't work (e.g. RVR, times, etc)
      var visibilityRegex = new RegExp(
          r"(?<!\/)(\b)[0-9]{4}(?!\/)\b");

      Color thisColor = Colors.black;

      if (visibilityRegex.hasMatch(currentWord)){

        // We need to include some exceptions for US codes
        // based on https://weather.cod.edu/notes/metar.html
        if (i > 0
            && splitMetar[i - 1] == "WSHFT") {
          thisSpan = TextSpan (
            text: currentWord + " ",
            style: TextStyle(color: thisColor),
          );
          spanList.add(thisSpan);
          continue;
        }

        try {
          int vis = int.tryParse(currentWord);
          if (vis <= _regularVisibility && vis > _badVisibility) {
            thisColor = Colors.orange;
          } else if (vis <= _badVisibility) {
            thisColor = Colors.red;
          }
          thisSpan = TextSpan(
            text: currentWord + " ",
            style: TextStyle(color: thisColor),
          );
        } catch (Exception) {
          thisSpan = TextSpan (
            text: currentWord + " ",
            style: TextStyle(color: thisColor),
          );
        }
        spanList.add(thisSpan);
        continue;
      }


      // RVR
      var rvrRegex = new RegExp(
          r"\b(R)+(\d\d([LCR]?))+(\/)+([PM]?)+([0-9]{4})+([UDN]?)\b");

      if (currentWord == "R/8888"){
        print("WORD");
      }

      if (rvrRegex.hasMatch(currentWord)) {

        TextSpan firstSpan;

        Color thisColor = Colors.black;
        try {
          int rvr;
          int addRunway = 0;
          int addExtreme = 0;
          int decreaseTrend = 0;

          if (currentWord.substring(3, 4) != "/") {
            addRunway = 1;
            if (currentWord.substring(5, 6) == "P" || currentWord.substring(5, 6) == "M") {
              addExtreme = 1;
            }
          } else {
            if (currentWord.substring(4, 5) == "P" || currentWord.substring(4, 5) == "M") {
              addExtreme = 1;
            }
          }
          if (currentWord[currentWord.length - 1] == "U"
              || currentWord[currentWord.length - 1] == "N"
              || currentWord[currentWord.length - 1] == "D") {
            decreaseTrend = 1;
          }

          rvr = int.tryParse(currentWord.substring(
              4 + addRunway + addExtreme, currentWord.length - decreaseTrend));

          String firstSplit = currentWord.substring(0, 4 + addRunway);

          String secondSplit = currentWord.substring(4 + addRunway);

          if (rvr <= _regularRvr && rvr >= _badRvr) {
            thisColor = Colors.orange;
          } else if (rvr < _badRvr) {
            thisColor = Colors.red;
          }
          firstSpan = TextSpan(
              text: firstSplit,
              style: TextStyle(color: Colors.black));
          thisSpan = TextSpan(
              text: secondSplit + " ",
              style: TextStyle(color: thisColor));
        } catch (Exception) {
          thisSpan = TextSpan (
            text: currentWord + " ",
            style: TextStyle(color: thisColor),
          );
        }
        spanList.add(firstSpan);
        spanList.add(thisSpan);
        continue;
      }

      // TEMPORARY
      var temporaryRegex = new RegExp(
          r"(PROB[0-9]{2} TEMPO)|(TEMPO)|(BECMG)|(FM)[0-9]{6}");
      if (temporaryRegex.hasMatch(currentWord)) {
          thisSpan = TextSpan(
              text: currentWord + " ",
              style: TextStyle(color: Colors.blue));
          spanList.add(thisSpan);
          continue;
      }

      // STANDARD (NOTHING FOUND)
      thisSpan = TextSpan(
        text: currentWord + " ",
        // This has to be here even with themes
        style: TextStyle(color: Colors.black),
      );
      spanList.add(thisSpan);
    }

    _colorizedResult = TextSpan (
      children: spanList,
    );
  }


  Future<void> _conditionDialog(String input) async {

    var condition = ConditionDecode(conditionString: input);
    ConditionModel decodedCondition = condition.getDecodedCondition;
    Widget myDecodedContainer = _decodedContainer(decodedCondition);

    return showDialog<void>(
      context: myContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(15,25,15,25),
              child: Column (
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text(
                    input,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                 myDecodedContainer,
                  RaisedButton(
                    child: Text(
                      'Roger!',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _decodedContainer(ConditionModel decodedCondition) {
    if (decodedCondition.error) {
      return Container(
        padding: EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("ERROR!"
                "\n\n"
                "Invalid runway condition.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    } else if (decodedCondition.isSnoclo) {
     return Container(
       padding: EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Text(
                "SNOCLO",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            Text(
              decodedCondition.snocloDecoded,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else if (decodedCondition.isClrd) {
      return Container(
        padding: EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    decodedCondition.rwyError ?
                    "(runway error)"
                        : "Runway ${decodedCondition.rwyValue}",
                    style: TextStyle(
                      fontSize: decodedCondition.rwyError ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: decodedCondition.rwyError ?
                      Colors.red : null,
                    ),
                  ),
                  Text(
                    " CLEARED",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              decodedCondition.clrdDecoded,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Runway
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.rwyCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.rwyDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Deposit type
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.depositCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.depositDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Extent
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.extentCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.extentDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Depth
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.depthCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.depthDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Runway
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.frictionCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.frictionDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

}