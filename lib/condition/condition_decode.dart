import 'package:flutter/material.dart';

class ConditionModel {
  bool error = false;

  bool rwyError = false;
  String rwyCode = "";
  String rwyValue = "";
  int rwyInt = 0;
  String rwyDecoded = "";

  String depositCode = "";
  bool depositError = false;

  String extentCode = "";
  bool extentError = false;

  String depthCode = "";
  bool depthError = false;
  int depthValue = 0;

  String frictionCode = "";
  bool frictionError = false;
  int frictionValue = 0;

  bool snoclo = false;
  bool clrd = false;
}


class ConditionDecode {

  String _conditionInput;
  ConditionModel _conditionModel;
  
  bool _mainError = false;


  get getDecodedCondition => _conditionModel;

  ConditionDecode({@required String conditionString}){
    _conditionInput = conditionString;

    int thisType = _discernType();
    _conditionModel = _fillConditionModel(thisType);
    _addDecodingToConditionModel();

  }


  int _discernType() {
    int conditionType;
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
        conditionType = 1;
      }
      // TYPE 2: R12/123456
      else if ((_conditionInput.substring(0, 1) == "R") &&
          (RegExp(r"\d").hasMatch(_conditionInput.substring(1, 2))) &&
          (_conditionInput.substring(3, 4) == "/") &&
          (RegExp(r"(([0-9]|\/){6})").hasMatch(_conditionInput.substring(4, 10))) &&
          (_conditionInput.length == 10))
      {
        conditionType = 2;
      }
      // TYPE 3: 88123456
      else if (RegExp(r"(\b)+(([0-9]|\/){8})+(\b)").hasMatch(_conditionInput))
      {
        conditionType = 3;
      }
      // TYPE 4: R/SNOCLO
      else if (RegExp(r"(\b)+(R\/SNOCLO)+(\b)").hasMatch(_conditionInput))
      {
        conditionType = 4;
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
        conditionType = 5;
      }
      // TYPE 6: R14/CLRD//
      else if ((_conditionInput.substring(0, 1) == "R") &&
          (RegExp(r"\d").hasMatch(_conditionInput.substring(1, 2))) &&
          (_conditionInput.substring(3, 4) == "/") &&
          (RegExp(r"(CLRD)+(\/\/)").hasMatch(_conditionInput.substring(4, 10))) &&
          (_conditionInput.length == 10)) {
        conditionType = 6;
      } else {
        _mainError = true;
      }
    } catch (Exception) {
      _mainError = true;
    }

    return conditionType;
  }

  ConditionModel _fillConditionModel (int thisType) {
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

      switch(thisType) {

        // (Type 1 for RXXL/123456)
        case 1:
          position2 += 3;
          position3 += 3;
          position4 += 3;
          position6 += 3;
          // RUNWAY CODE
          try {
            int intRunway = int.tryParse(_conditionInput.substring(1, 3));
            if (intRunway <= 36) {
              myConditionModel.rwyCode = _conditionInput.substring(0, 4);
              myConditionModel.rwyValue = _conditionInput.substring(1, 4);
              myConditionModel.rwyInt = intRunway;
            } else {
              myConditionModel.rwyCode = _conditionInput.substring(0, 4);
              myConditionModel.rwyError = true;
            }
          } catch (Exception) {
            myConditionModel.rwyCode = _conditionInput.substring(0, 5);
            myConditionModel.rwyError = true;
          }
          break;

        // (Type 2 for RXX/123456)
        case 2:
          position2 += 2;
          position3 += 2;
          position4 += 2;
          position6 += 2;

          // RUNWAY CODE
          try {
            int intRunway = int.tryParse(_conditionInput.substring(1, 3));
            if (intRunway <= 36 || intRunway == 88 || intRunway == 99) {
              myConditionModel.rwyCode = _conditionInput.substring(0, 3);
              myConditionModel.rwyValue = _conditionInput.substring(1, 3);
              myConditionModel.rwyInt = intRunway;
            } else {
              myConditionModel.rwyCode = _conditionInput.substring(0, 3);
              myConditionModel.rwyError = true;
            }
          } catch (Exception) {
            myConditionModel.rwyCode = _conditionInput.substring(0, 3);
            myConditionModel.rwyError = true;
          }
          break;

        // (Type 3 for XX123456)
        case 3:
          try {
            int intRunway = int.tryParse(_conditionInput.substring(0, 2));

            myConditionModel.rwyCode = _conditionInput.substring(0, 2);
            myConditionModel.rwyValue = _conditionInput.substring(0, 2);
            myConditionModel.rwyInt = intRunway;

            if (!(intRunway <= 36 || intRunway == 88 || intRunway == 99)) {
              myConditionModel.rwyCode = _conditionInput.substring(0, 2);
              myConditionModel.rwyError = true;
            }
          } catch (Exception) {
            myConditionModel.rwyCode = _conditionInput.substring(0, 2);
            myConditionModel.rwyError = true;
          }
          break;
      }

      // We only need to calculate deposit, extent, depth and friction for conditions 1, 2 or 3
      if (thisType < 4) {

        // DEPOSIT TYPE
        try {
          if (_conditionInput.substring(position2, position2 + 1) == "/") {
            myConditionModel.depositCode = "/";
          } else {
            myConditionModel.depositCode = _conditionInput.substring(position2, position2 + 1);

            if (int.tryParse(_conditionInput.substring(position2, position2 + 1)) == null) {
              myConditionModel.depositError = true;
            }
          }
        } catch (Exception) {
          myConditionModel.depositCode = _conditionInput.substring(position2, position2 + 1);
          myConditionModel.depositError = true;
        }

        // EXTENT TYPE
        try {
          if (_conditionInput.substring(position3, position3 + 1) == "/") {
            myConditionModel.extentCode = "/";
          } else {
            int intExtent = int.tryParse(_conditionInput.substring(position3, position3 + 1));
            if (intExtent != null) {
              myConditionModel.extentCode = _conditionInput.substring(position3, position3 + 1);
              if (!(intExtent == 1 || intExtent == 2 || intExtent == 5 || intExtent == 9)) {
                myConditionModel.extentError = true;
              }
            } else {
              myConditionModel.extentError = true;
            }
          }
        }
        catch (Exception) {
          myConditionModel.extentCode = _conditionInput.substring(position3, position3 + 1);
          myConditionModel.extentError = true;
        }

        // DEPTH
        try {
          if (_conditionInput.substring(position4, position4 + 2) == "//") {
            myConditionModel.depthCode = "//";
          } else {
            myConditionModel.depthCode = _conditionInput.substring(position4, position4 + 2);
            int intDepth = int.tryParse(_conditionInput.substring(position4, position4 + 2));
            if (intDepth != null) {
              myConditionModel.depthValue = intDepth;
              if (intDepth == 91) {
                myConditionModel.depthError = true;
              }
            } else {
              myConditionModel.depthError = true;
            }
          }
        } catch (Exception) {
          myConditionModel.depthCode = _conditionInput.substring(position4, position4 + 2);
          myConditionModel.depthError = true;
        }

        // FRICTION
        try {
          if (_conditionInput.substring(position6, position6 + 2) == "//") {
            myConditionModel.frictionCode = "//";
          } else {
            myConditionModel.frictionCode = _conditionInput.substring(position6, position6 + 2);
            int intFriction = int.tryParse(_conditionInput.substring(position6, position6 + 2));
            if (intFriction != null) {
              myConditionModel.frictionValue = intFriction;
              if (intFriction >= 96 && intFriction <= 98) {
                myConditionModel.frictionError = true;
              }
            } else {
              myConditionModel.frictionError = true;
            }
          }
        } catch (Exception) {
          myConditionModel.frictionCode = _conditionInput.substring(position6, position6 + 2);
          myConditionModel.frictionError = true;
        }

      // Conditions type 4, 5 or 6
      } else {
        // R/SNOCLO
        if (thisType == 4) {
          myConditionModel.snoclo = true;
        }
        // RXXL/CLRD//
        else if (thisType == 5) {
          myConditionModel.clrd = true;

          try {
            int intRunway = int.tryParse(_conditionInput.substring(1, 3));
            if (intRunway <= 36) {
              myConditionModel.rwyCode = _conditionInput.substring(0, 4);
              myConditionModel.rwyValue = _conditionInput.substring(1, 4);
              myConditionModel.rwyInt = intRunway;
            } else {
              myConditionModel.rwyCode = _conditionInput.substring(0, 4);
              myConditionModel.rwyError = true;
            }
          } catch (Exception) {
            myConditionModel.rwyCode = _conditionInput.substring(0, 4);
            myConditionModel.rwyError = true;
          }
        }
        // RXX/CLRD//
        else if (thisType == 6) {
          myConditionModel.clrd = true;

          try {
            int intRunway = int.tryParse(_conditionInput.substring(1, 3));
            if (intRunway <= 36 || intRunway == 88 || intRunway == 99) {
              myConditionModel.rwyCode = _conditionInput.substring(0, 3);
              myConditionModel.rwyValue = _conditionInput.substring(1, 3);
              myConditionModel.rwyInt = intRunway;
            } else {
              myConditionModel.rwyCode = _conditionInput.substring(0, 3);
              myConditionModel.rwyError = true;
            }
          } catch (Exception) {
            myConditionModel.rwyCode = _conditionInput.substring(0, 3);
            myConditionModel.rwyError = true;
          }
        }
      }
    }

    return myConditionModel;
  }

  _addDecodingToConditionModel () {
    // RWY Decoding
    if (_conditionModel.rwyError) {
      _conditionModel.rwyDecoded = "Error! Runway not valid";
    } else {
     if (_conditionModel.rwyInt <= 36) {
       _conditionModel.rwyDecoded = "Runway ${_conditionModel.rwyInt}";
     } else if (_conditionModel.rwyInt == 88) {
       _conditionModel.rwyDecoded = "All runways";
     } else if (_conditionModel.rwyInt == 99) {
       _conditionModel.rwyDecoded = "Previous report being repeated";
     }
    }

    // DEPOSIT Decoding


    // EXTENT Decoding


    // Depth Decoding


    // Friction Decoding


    // SNOCLO


    // CLRD



  }

}


