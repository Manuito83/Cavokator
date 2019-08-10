import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class TempRepeaterWidget extends StatefulWidget {
  final bool currentError;
  final int elevation;
  final int temperature;
  final Stream elevationParentValueChange;
  final Stream temperatureParentValueChange;
  final Stream errorParentValueChange;
  final int repeaterId;
  final Function callbackValue;
  final String presetValue;

  TempRepeaterWidget({
    @required this.currentError,
    @required this.elevation,
    @required this.temperature,
    @required this.elevationParentValueChange,
    @required this.temperatureParentValueChange,
    @required this.errorParentValueChange,
    @required this.repeaterId,
    @required this.callbackValue,
    this.presetValue,
  });

  @override
  _TempRepeaterWidget createState() => _TempRepeaterWidget();
}

class _TempRepeaterWidget extends State<TempRepeaterWidget> {
  StreamSubscription errorStreamSubscription;
  StreamSubscription elevationStreamSubscription;
  StreamSubscription temperatureStreamSubscription;

  final _myTextController = new TextEditingController();
  bool parentError;
  bool altitudeError = false;
  int parentElevation;
  int parentTemperature;
  int _myValue;

  @override
  void initState() {
    super.initState();

    _myTextController.addListener(_onInputTextChange);

    if (widget.presetValue != null) {
      _myValue = int.parse(widget.presetValue);
      _myTextController.text = _myValue.toString();
    }

    if (_myValue == null) {
      altitudeError = true;
    }

    parentError = widget.currentError;
    parentElevation = widget.elevation;
    parentTemperature = widget.temperature;

    errorStreamSubscription =
        widget.errorParentValueChange.listen((data) => _onParentErrorChange(data));
    elevationStreamSubscription =
        widget.elevationParentValueChange.listen((data) => _onParentElevationChange(data));
    temperatureStreamSubscription =
        widget.temperatureParentValueChange.listen((data) => _onParentTemperatureChange(data));


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
                  Text("Altitude",
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
                  Text("Corrected",
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
    super.dispose();
    errorStreamSubscription.cancel();
    elevationStreamSubscription.cancel();
    temperatureStreamSubscription.cancel();
  }

  void _onInputTextChange() {
    setState(() {
      _myValue = int.tryParse(_myTextController.text);
      if (_myValue == null || _myValue < -2000 || _myValue > 40000) {
        altitudeError = true;
      } else {
        widget.callbackValue(widget.repeaterId, _myValue);
        altitudeError = false;
      }
    });
  }

  Widget _correctedTextWidget () {
    if (parentError || altitudeError) {
      return Text("");
    } else {
      try {
        String corrected = _calculateResult(parentElevation, parentTemperature, _myValue).toString();
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
        parentError = true;
      } else {
        parentError = false;
      }
    });
  }

  _onParentElevationChange(int dataChanged) {
    setState(() {
      parentElevation = dataChanged;
    });
  }

  _onParentTemperatureChange(int dataChanged) {
    setState(() {
      parentTemperature = dataChanged;
    });
  }

  int _calculateResult (int elevation, int temperature, int altitude) {
    double correction =
        (altitude-elevation)*((15-(temperature+0.00198*elevation))
        /(273+(temperature+0.00198*elevation)
        -(0.5*0.00198*((altitude-elevation)+elevation))));

    return correction.round() + altitude;
  }



}