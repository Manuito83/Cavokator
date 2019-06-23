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
  String depositDecoded = "";

  String extentCode = "";
  bool extentError = false;
  String extentDecoded = "";

  String depthCode = "";
  bool depthError = false;
  int depthValue = 0;
  String depthDecoded = "";

  String frictionCode = "";
  bool frictionError = false;
  int frictionValue = 0;
  String frictionDecoded = "";

  bool isSnoclo = false;
  String snocloDecoded = "";

  bool isClrd = false;
  String clrdDecoded = "";
}


class ConditionDecode {

  String _conditionInput;
  ConditionModel _conditionModel = ConditionModel();
  
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
              if (intExtent != 1 && intExtent != 2 && intExtent != 5 && intExtent != 9) {
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
          myConditionModel.isSnoclo = true;
        }
        // RXXL/CLRD//
        else if (thisType == 5) {
          myConditionModel.isClrd = true;

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
          myConditionModel.isClrd = true;

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
       _conditionModel.rwyDecoded = "Runway ${_conditionModel.rwyValue}";
     } else if (_conditionModel.rwyInt == 88) {
       _conditionModel.rwyDecoded = "All runways";
     } else if (_conditionModel.rwyInt == 99) {
       _conditionModel.rwyDecoded = "Previous report being repeated";
     }
    }

    // DEPOSIT Decoding
    if (_conditionModel.depositError){
      _conditionModel.depositDecoded = "Error! Deposit code not valid";
    } else {
      switch (_conditionModel.depositCode){
        case "/":
          _conditionModel.depositDecoded = "Clear and dry";
          break;
        case "0":
          _conditionModel.depositDecoded = "Damp";
          break;
        case "1":
          _conditionModel.depositDecoded = "Wet and water patches";
          break;
        case "2":
          _conditionModel.depositDecoded = "Rime and frost covered (depth normally less than 1 mm)";
          break;
        case "3":
          _conditionModel.depositDecoded = "Dry snow";
          break;
        case "4":
          _conditionModel.depositDecoded = "Wet snow";
          break;
        case "5":
          _conditionModel.depositDecoded = "Slush";
          break;
        case "6":
          _conditionModel.depositDecoded = "Ice";
          break;
        case "7":
          _conditionModel.depositDecoded = "Compacted or rolled snow";
          break;
        case "8":
          _conditionModel.depositDecoded = "Frozen ruts or ridges";
          break;
        case "9":
          _conditionModel.depositDecoded = "Type of deposit not reported";
          break;
      }
    }

    // EXTENT Decoding
    if (_conditionModel.extentError){
      _conditionModel.extentDecoded = "Error! Extent code not valid";
    } else {
      switch (_conditionModel.extentCode){
        case "/":
          _conditionModel.extentDecoded = "Contamination extent not reported";
          break;
        case "1":
          _conditionModel.extentDecoded = "Less than 10% of runway contaminated (covered)";
          break;
        case "2":
          _conditionModel.extentDecoded = "11% to 25% of runway contaminated (covered)";
          break;
        case "5":
          _conditionModel.extentDecoded = "26% to 50% of runway contaminated (covered)";
          break;
        case "9":
          _conditionModel.extentDecoded = "51% to 100% of runway contaminated (covered)";
          break;
        default:
          _conditionModel.extentDecoded = "Error! Extent code not valid";
          break;
      }
    }

    // Depth Decoding
    if (_conditionModel.depthError){
      _conditionModel.depthDecoded = "Error! Depth code not valid";
    } else {
      if (_conditionModel.depthCode == "//") {
        _conditionModel.depthDecoded = "Depth of deposit operationally not significant or not measurable";
      } else if (_conditionModel.depthValue == 0) {
        _conditionModel.depthDecoded = "Depth less than 1 mm";
      } else if (_conditionModel.depthValue >= 1 && _conditionModel.depthValue <= 90) {
        _conditionModel.depthDecoded = "Depth ${_conditionModel.depthValue} mm";
      } else if (_conditionModel.depthValue >= 92 && _conditionModel.depthValue <= 97) {
        switch (_conditionModel.depthValue) {
          case (92):
            _conditionModel.depthDecoded = "Depth 10 cm";
            break;
          case (93):
            _conditionModel.depthDecoded = "Depth 15 cm";
            break;
          case (94):
            _conditionModel.depthDecoded = "Depth 20 cm";
            break;
          case (95):
            _conditionModel.depthDecoded = "Depth 25 cm";
            break;
          case (96):
            _conditionModel.depthDecoded = "Depth 30 cm";
            break;
          case (97):
            _conditionModel.depthDecoded = "Depth 35 cm";
            break;
          case (98):
            _conditionModel.depthDecoded = "Depth 40 cm or more";
            break;
        } 
      } else if (_conditionModel.depthValue == 99) {
        _conditionModel.depthDecoded = "Runway or runways non-operational "
            "due to snow, slush, ice, large drifts or runway "
            "clearance, but depth not reported";
      } else {
        _conditionModel.depthDecoded = "Error! Depth code not valid";
      }
    }

    // Friction Decoding
    if (_conditionModel.frictionError){
      _conditionModel.frictionDecoded = "Error! Friction code not valid";
    } else {
      if (_conditionModel.frictionCode == "//") {
        _conditionModel.frictionDecoded = "Braking conditions not reported and/or runway not operational";
      } else if (_conditionModel.frictionValue >= 1 && _conditionModel.frictionValue <= 90) {
        _conditionModel.frictionDecoded = "Friction coefficient .${_conditionModel.frictionValue}";
      } else if (_conditionModel.frictionValue >= 91 && _conditionModel.frictionValue <= 95) {
        switch (_conditionModel.frictionValue) {
          case (91):
            _conditionModel.frictionDecoded = "Braking action poor";
            break;
          case (92):
            _conditionModel.frictionDecoded = "Braking action medium/poor";
            break;
          case (93):
            _conditionModel.frictionDecoded = "Braking action medium";
            break;
          case (94):
            _conditionModel.frictionDecoded = "Braking action medium/good";
            break;
          case (95):
            _conditionModel.frictionDecoded = "Braking action good";
            break;
        }
      } else if (_conditionModel.frictionValue == 99) {
        _conditionModel.frictionDecoded = "Friction coefficient unreliable";
      } else {
        _conditionModel.frictionDecoded = "Error! Friction code not valid";
      }
    }

    // SNOCLO
    if (_conditionModel.isSnoclo) {
      _conditionModel.snocloDecoded = "Aerodrome is closed due to extreme deposit of snow";
    }

    // CLRD
    if (_conditionModel.isClrd) {
      _conditionModel.clrdDecoded = "Contaminations have ceased to exist (CLEARED)";
    }
  }

}


