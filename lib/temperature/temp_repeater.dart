import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class TempRepeaterWidget extends StatefulWidget {
  final bool currentError;
  final int elevation;
  final int temperature;
  final bool round;
  final Stream elevationParentValueChange;
  final Stream temperatureParentValueChange;
  final Stream errorParentValueChange;
  final Stream roundParentValueChange;
  final int repeaterId;
  final Function callbackValue;
  final Function callbackCorrection;
  final String presetValue;

  TempRepeaterWidget({
    @required Key key,
    @required this.currentError,
    @required this.elevation,
    @required this.temperature,
    @required this.round,
    @required this.elevationParentValueChange,
    @required this.temperatureParentValueChange,
    @required this.errorParentValueChange,
    @required this.roundParentValueChange,
    @required this.repeaterId,
    @required this.callbackValue,
    @required this.callbackCorrection,
    @required this.presetValue,
  }) : super(key: key) ;

  @override
  _TempRepeaterWidget createState() => _TempRepeaterWidget();
}

class _TempRepeaterWidget extends State<TempRepeaterWidget> {
  StreamSubscription errorStreamSubscription;
  StreamSubscription elevationStreamSubscription;
  StreamSubscription temperatureStreamSubscription;
  StreamSubscription roundStreamSubscription;

  final _myTextController = new TextEditingController();
  bool _parentError;
  bool _altitudeError = false;
  bool _altitudeNull = false;
  int _parentElevation;
  int _parentTemperature;
  bool _parentRound;

  int _myValue;
  int _myCorrection;

  @override
  void initState() {
    super.initState();

    _myTextController.addListener(_onInputTextChange);

    if (widget.presetValue != null) {
      _myValue = int.tryParse(widget.presetValue);
      _myTextController.text = _myValue.toString();
    }

    if (_myValue == null) {
      _altitudeNull = true;
    }

    _parentError = widget.currentError;
    _parentElevation = widget.elevation;
    _parentTemperature = widget.temperature;
    _parentRound = widget.round;

    errorStreamSubscription =
        widget.errorParentValueChange.listen((data) => _onParentErrorChange(data));
    elevationStreamSubscription =
        widget.elevationParentValueChange.listen((data) => _onParentElevationChange(data));
    temperatureStreamSubscription =
        widget.temperatureParentValueChange.listen((data) => _onParentTemperatureChange(data));
    roundStreamSubscription =
        widget.roundParentValueChange.listen((data) => _onParentRoundChange(data));


  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: Column(
        children: <Widget>[
          Row (
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text("Altitude (ft)",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
              ),
              Text("|",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )
              ),
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
                      )
                  ),
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
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(5),
                        ],
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        keyboardType: TextInputType.numberWithOptions(),
                        maxLines: 1,
                        controller: _myTextController,
                        autovalidate: true,
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "";
                          } else {
                            int myAltitude = int.tryParse(value);
                            if (myAltitude == null) {
                              return "Error";
                            }
                            if (myAltitude < -2000 || myAltitude > 40000) {
                              return "Error";
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
    errorStreamSubscription.cancel();
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
      } else if (_myValue < -2000 || _myValue > 15000) {
        widget.callbackValue(widget.repeaterId, _myValue);
        _altitudeError = true;
        _altitudeNull = false;
      } else {
        widget.callbackValue(widget.repeaterId, _myValue);
        _altitudeError = false;
        _altitudeNull = false;
      }
    });
  }

  Widget _correctedTextWidget () {
    if (_parentError || _altitudeNull) {
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
        _calculateResult(_parentElevation, _parentTemperature, _myValue);
        String corrected = _myCorrection.toString();
        widget.callbackCorrection(widget.repeaterId, _myCorrection);
        return Text(
            corrected,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            )
        );
      } catch (e) {
        return Text(
            "error",
            style: TextStyle(
              color: Colors.red,
              fontSize: 15,
            )
        );
      }
    }
  }

  _onParentErrorChange(int dataChanged) {
    setState(() {
      if (dataChanged == 1) {
        _parentError = true;
      } else {
        _parentError = false;
      }
    });
  }

  _onParentElevationChange(int dataChanged) {
    setState(() {
      _parentElevation = dataChanged;
    });
  }

  _onParentTemperatureChange(int dataChanged) {
    setState(() {
      _parentTemperature = dataChanged;
    });
  }

  _onParentRoundChange(bool dataChanged) {
    setState(() {
      _parentRound = dataChanged;
    });
  }

  void _calculateResult (int elevation, int temperature, int altitude) {
    double correction =
        (altitude-elevation)*((15-(temperature+0.00198*elevation))
        /(273+(temperature+0.00198*elevation)
        -(0.5*0.00198*((altitude-elevation)+elevation)))
    );

    int exactResult = correction.round() + altitude;

    if (_parentRound) {
      _myCorrection = ((exactResult / 100).ceil())*100;
    } else {
      _myCorrection = exactResult;
    }
  }

}