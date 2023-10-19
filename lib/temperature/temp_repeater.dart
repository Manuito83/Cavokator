import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TempRepeaterWidget extends StatefulWidget {
  final bool currentElevationError;
  final bool currentTemperatureError;
  final int? elevation;
  final int? temperature;
  final int round;
  final Stream elevationParentValueChange;
  final Stream temperatureParentValueChange;
  final Stream elevationErrorParentValueChange;
  final Stream temperatureErrorParentValueChange;
  final Stream roundParentValueChange;
  final int repeaterId;
  final Function callbackValue;
  final Function callbackCorrection;
  final String? presetValue;

  TempRepeaterWidget({
    required Key key,
    required this.currentElevationError,
    required this.currentTemperatureError,
    required this.elevation,
    required this.temperature,
    required this.round,
    required this.elevationParentValueChange,
    required this.temperatureParentValueChange,
    required this.elevationErrorParentValueChange,
    required this.temperatureErrorParentValueChange,
    required this.roundParentValueChange,
    required this.repeaterId,
    required this.callbackValue,
    required this.callbackCorrection,
    required this.presetValue,
  }) : super(key: key);

  @override
  _TempRepeaterWidget createState() => _TempRepeaterWidget();
}

class _TempRepeaterWidget extends State<TempRepeaterWidget> {
  late StreamSubscription elevationErrorStreamSubscription;
  late StreamSubscription temperatureErrorStreamSubscription;
  late StreamSubscription elevationStreamSubscription;
  late StreamSubscription temperatureStreamSubscription;
  late StreamSubscription roundStreamSubscription;

  final _myTextController = TextEditingController();
  late bool _parentElevationError;
  late bool _parentTemperatureError;
  bool _altitudeError = false;
  bool _altitudeNull = false;
  bool _altitudeLow = false;
  int? _parentElevation;
  int? _parentTemperature;
  int? _parentRound;

  int? _myValue;
  int? _myCorrection;

  @override
  void initState() {
    super.initState();

    _parentElevationError = widget.currentElevationError;
    _parentTemperatureError = widget.currentTemperatureError;
    _parentElevation = widget.elevation;
    _parentTemperature = widget.temperature;
    _parentRound = widget.round;

    _myTextController.addListener(_onInputTextChange);

    if (widget.presetValue != null) {
      _myValue = int.tryParse(widget.presetValue!);
      _myTextController.text = _myValue.toString();
    }

    if (_myValue == null) {
      _altitudeNull = true;
    }

    elevationErrorStreamSubscription =
        widget.elevationErrorParentValueChange.listen((data) => _onParentElevationErrorChange(data));
    temperatureErrorStreamSubscription =
        widget.temperatureErrorParentValueChange.listen((data) => _onParentTemperatureErrorChange(data));
    elevationStreamSubscription = widget.elevationParentValueChange.listen((data) => _onParentElevationChange(data));
    temperatureStreamSubscription =
        widget.temperatureParentValueChange.listen((data) => _onParentTemperatureChange(data));
    roundStreamSubscription = widget.roundParentValueChange.listen((data) => _onParentRoundChange(data));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text("Altitude (ft)",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
              ),
              Text("|",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Corrected (ft)",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 70,
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(5),
                        ],
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        keyboardType: TextInputType.numberWithOptions(signed: true),
                        maxLines: 1,
                        controller: _myTextController,
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "";
                          } else {
                            int? myAltitude = int.tryParse(value);
                            if (myAltitude == null) {
                              return "Error";
                            }
                            if (myAltitude < -2000 || myAltitude > 15000) {
                              return "Error";
                            }
                            if (myAltitude < _parentElevation! && !(_parentElevationError || _parentTemperatureError)) {
                              return "Too low!";
                            }
                            return null;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _correctedTextWidget(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  dispose() {
    elevationErrorStreamSubscription.cancel();
    temperatureErrorStreamSubscription.cancel();
    elevationStreamSubscription.cancel();
    temperatureStreamSubscription.cancel();
    roundStreamSubscription.cancel();
    super.dispose();
  }

  void _onInputTextChange() {
    setState(() {
      _myValue = int.tryParse(_myTextController.text);
      if (_myValue == null) {
        _altitudeNull = true;
      } else if (_myValue! < _parentElevation!) {
        _altitudeNull = false;
        _altitudeLow = true;
      } else if (_myValue! < -2000 || _myValue! > 15000) {
        widget.callbackValue(widget.repeaterId, _myValue);
        _altitudeError = true;
        _altitudeNull = false;
        _altitudeLow = false;
      } else {
        widget.callbackValue(widget.repeaterId, _myValue);
        _altitudeError = false;
        _altitudeNull = false;
        _altitudeLow = false;
      }
    });
  }

  Widget _correctedTextWidget() {
    if (_parentElevationError || _parentTemperatureError || _altitudeNull) {
      return Text("");
    } else if (_altitudeLow) {
      return Text("");
    } else if (_altitudeError) {
      return Text(
        "error",
        style: TextStyle(
          color: Colors.red,
          fontSize: 15,
        ),
      );
    } else {
      try {
        _calculateResult(_parentElevation!, _parentTemperature!, _myValue!);
        String corrected = _myCorrection.toString();
        widget.callbackCorrection(widget.repeaterId, _myCorrection);
        return Text(corrected,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ));
      } catch (e) {
        return Text("error",
            style: TextStyle(
              color: Colors.red,
              fontSize: 15,
            ));
      }
    }
  }

  _onParentElevationErrorChange(int dataChanged) {
    setState(() {
      if (dataChanged == 1) {
        _parentElevationError = true;
      } else {
        _parentElevationError = false;
      }
    });
  }

  _onParentTemperatureErrorChange(int dataChanged) {
    setState(() {
      if (dataChanged == 1) {
        _parentTemperatureError = true;
      } else {
        _parentTemperatureError = false;
      }
    });
  }

  _onParentElevationChange(int dataChanged) {
    if (!_altitudeNull) {
      if (_myValue! < dataChanged) {
        _altitudeLow = true;
      } else {
        _altitudeLow = false;
      }
    }
    setState(() {
      _parentElevation = dataChanged;
    });
  }

  _onParentTemperatureChange(int dataChanged) {
    setState(() {
      _parentTemperature = dataChanged;
    });
  }

  _onParentRoundChange(int dataChanged) {
    setState(() {
      _parentRound = dataChanged;
    });
  }

  void _calculateResult(int elevation, int temperature, int altitude) {
    double correction = (altitude - elevation) *
        ((15 - (temperature + 0.00198 * elevation)) /
            (273 + (temperature + 0.00198 * elevation) - (0.5 * 0.00198 * ((altitude - elevation) + elevation))));

    int exactResult = correction.round() + altitude;

    if (_parentRound == 0) {
      _myCorrection = exactResult;
    } else if (_parentRound == 10) {
      _myCorrection = ((exactResult / 10).ceil()) * 10;
    } else if (_parentRound == 50) {
      _myCorrection = ((exactResult / 50).ceil()) * 50;
    } else if (_parentRound == 100) {
      _myCorrection = ((exactResult / 100).ceil()) * 100;
    }
  }
}
