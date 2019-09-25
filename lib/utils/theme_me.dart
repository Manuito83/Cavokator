import 'package:flutter/material.dart';

enum DesiredColor
{
  MainBackground,
  MainText,
  HeaderPinned,
  HeaderUnpinned,
  BlueTempo,
  MagentaCategory,
  Buttons,
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
    var _colorMainTextLIGHT = Colors.black;
    var _colorHeaderPinnedLIGHT = Colors.red[300];
    var _colorHeaderUnpinnedLIGHT = Colors.lightBlue;
    var _colorBlueTempoLIGHT = Colors.blue;
    var _colorMagentaCategoryLIGHT = Colors.deepPurple;
    var _colorButtonsLIGHT = Colors.grey[400];

    // COLORS ##DARK##
    var _colorMainBackgroundDARK = Colors.grey[800];
    var _colorMainTextDARK = Colors.grey[50];
    var _colorHeaderPinnedDARK = Colors.red[800];
    var _colorHeaderUnpinnedDARK = Colors.lightBlue[800];
    var _colorBlueTempoDARK = Colors.blue[400];
    var _colorMagentaCategoryDARK = Colors.deepPurple[300];
    var _colorButtonsDARK = Colors.grey[700];

    switch (desiredColor){
      case DesiredColor.MainBackground:
        return themeDark ? _colorMainBackgroundDARK : _colorMainBackgroundLIGHT;
      case DesiredColor.MainText:
        return themeDark ? _colorMainTextDARK : _colorMainTextLIGHT;
      case DesiredColor.HeaderPinned:
        return themeDark ? _colorHeaderPinnedDARK : _colorHeaderPinnedLIGHT;
      case DesiredColor.HeaderUnpinned:
        return themeDark ? _colorHeaderUnpinnedDARK : _colorHeaderUnpinnedLIGHT;
      case DesiredColor.BlueTempo:
        return themeDark ? _colorBlueTempoDARK : _colorBlueTempoLIGHT;
      case DesiredColor.MagentaCategory:
        return themeDark ? _colorMagentaCategoryDARK : _colorMagentaCategoryLIGHT;
      case DesiredColor.Buttons:
        return themeDark ? _colorButtonsDARK : _colorButtonsLIGHT;
      default:
        return Colors.red;
    }
  }
}