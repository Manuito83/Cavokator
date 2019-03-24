import 'package:flutter/material.dart';

enum DesiredColor
{
  MainBackground,
  //MainText,
  //RedTextWarning,
  //YellowText,
  //GreenText,
  //CyanText,
  //MagentaText,
  //TextHint,
  //CardViews,
  //LightYellowBackground
}

class ThemeMe {

  static Color apply (bool themeDark, DesiredColor desiredColor){

    // COLORS ##LIGHT##
    var _colorMainBackgroundLIGHT = Colors.grey[200];

    // COLORS ##DARK##
    var _colorMainBackgroundDARK = Colors.grey[700];

    switch (desiredColor){
      case DesiredColor.MainBackground:
        return themeDark ? _colorMainBackgroundDARK : _colorMainBackgroundLIGHT;
      default:
        return Colors.red;
    }
  }
}