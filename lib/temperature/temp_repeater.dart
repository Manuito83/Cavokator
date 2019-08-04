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

  TempRepeaterWidget({
    @required this.currentError,
    @required this.elevation,
    @required this.temperature,
    @required this.elevationParentValueChange,
    @required this.temperatureParentValueChange,
    @required this.errorParentValueChange,
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
  int parentElevation;
  int parentTemperature;
  int _myValue; // TODO: we need to initialize to null so that we can give error

  @override
  void initState() {
    super.initState();

    if (_myValue == null) {
      parentError = true;
    }

    parentError = widget.currentError;
    parentElevation = widget.elevation;
    parentTemperature = widget.temperature;
    errorStreamSubscription =
        widget.errorParentValueChange.listen((data) => onParentErrorChange(data));
    elevationStreamSubscription =
        widget.elevationParentValueChange.listen((data) => onParentElevationChange(data));
    temperatureStreamSubscription =
        widget.temperatureParentValueChange.listen((data) => onParentTemperatureChange(data));
    _myTextController.addListener(_onInputTextChange);
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
      if (_myValue == null) {
        parentError = true;     // TODO: USE SOMETHING DIFFERENT FROM PARENTERROR (TO INITIALIZE BLANK!)
      } else {
        parentError = false;
      }
    });
  }

  Widget _correctedTextWidget () {
    if (parentError) {
      return Text(
          "error",
          style: TextStyle(
            color: Colors.red,
            fontSize: 15,
          )
      );
    } else {
      try {
        String corrected = (_myValue * parentTemperature + parentElevation).toString();
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

  onParentErrorChange(int dataChanged) {
    setState(() {
      if (dataChanged == 1) {
        parentError = true;
      } else {
        parentError = false;
      }
    });
  }

  onParentElevationChange(int dataChanged) {
    setState(() {
      parentElevation = dataChanged;
    });
  }

  onParentTemperatureChange(int dataChanged) {
    setState(() {
      parentTemperature = dataChanged;
    });
  }

}