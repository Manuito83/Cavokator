import 'package:flutter/material.dart';

class ConditionModel {
  bool error = false;

}


class ConditionDecode {

  String _conditionInput;
  ConditionModel _conditionModel;
  
  bool _mainError = false;
  int _conditionType = 0;
  

  get getDecodedCondition => _conditionModel;

  ConditionDecode({@required String conditionString}){
    _conditionInput = conditionString;

    _discernType();
    _conditionModel = _fillConditionModel();

  }


  void _discernType() {
    try
    {
      // TYPE 1: R12L/123456
      if ((_conditionInput.substring(0, 1) == "R") &&
          (RegExp(r"\d").hasMatch(_conditionInput.substring(1, 2))) &&
          (RegExp(r"\d").hasMatch(_conditionInput.substring(2, 3))) &&
          (RegExp("[L|R|C]").hasMatch(_conditionInput.substring(3, 4))) &&
          (_conditionInput.substring(4, 5) == "/") &&
          (RegExp(r"(([0-9]|\/){6})").hasMatch(_conditionInput.substring(5, 11))) &&
          (_conditionInput.length == 11))
      {
        _conditionType = 1;
      }
      // TYPE 2: R12/123456
      else if ((_conditionInput.substring(0, 1) == "R") &&
          (RegExp(r"\d").hasMatch(_conditionInput.substring(1, 2))) &&
          (_conditionInput.substring(3, 4) == "/") &&
          (RegExp(r"(([0-9]|\/){6})").hasMatch(_conditionInput.substring(4, 10))) &&
          (_conditionInput.length == 10))
      {
        _conditionType = 2;
      }
      // TYPE 3: 88123456
      else if (RegExp(r"(\b)+(([0-9]|\/){8})+(\b)").hasMatch(_conditionInput))
      {
        _conditionType = 3;
      }
      // TYPE 4: R/SNOCLO
      else if (RegExp(r"(\b)+(R\/SNOCLO)+(\b)").hasMatch(_conditionInput))
      {
        _conditionType = 4;
      }
      // TYPE 5: R14L/CLRD//
      else if ((_conditionInput.substring(0, 1) == "R") &&
          (RegExp(r"\d").hasMatch(_conditionInput.substring(1, 2))) &&
          (RegExp(r"\d").hasMatch(_conditionInput.substring(2, 3))) &&
          (RegExp(r"[L|R|C]").hasMatch(_conditionInput.substring(3, 4))) &&
          (_conditionInput.substring(4, 5) == "/") &&
          (RegExp(r"(CLRD)+(\/\/)").hasMatch(_conditionInput.substring(5, 11))) &&
          (_conditionInput.length == 11))
      {
        _conditionType = 5;
      }
      // TYPE 6: R14/CLRD//
      else if ((_conditionInput.substring(0, 1) == "R") &&
          (RegExp(r"\d").hasMatch(_conditionInput.substring(1, 2))) &&
          (_conditionInput.substring(3, 4) == "/") &&
          (RegExp(r"(CLRD)+(\/\/)").hasMatch(_conditionInput.substring(4, 10))) &&
          (_conditionInput.length == 10)) {
        _conditionType = 6;
      } else {
        _mainError = true;
      }
    } catch (Exception) {
      _mainError = true;
    }
  }

  ConditionModel _fillConditionModel () {
    var myConditionModel = ConditionModel();
    if (_mainError) {
      myConditionModel.error = true;
    } else {

      // To avoid excess clutter, we will analyse the RUNWAY for each type (as the numbers of characters change).
      // But then, for the other fields, we will just add a correction to identify the right number.

      int position2 = 2;
      int position3 = 3;
      int position4 = 4;
      int position6 = 6;

      switch(_conditionType) {

        // (Type 1 for RXXL/123456)
        case 1:

          break;

        // (Type 2 for RXX/123456)
        case 2:

          break;

        // (Type 3 for XX123456)
        case 3:

          break;
      }

      // We only need to calculate deposit, extent, depth and friction for conditions 1, 2 or 3


    }

    return myConditionModel;
  }

}


