import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class TempRepeaterWidget extends StatefulWidget {
  final int temperature;
  final Stream parentValueChange;

  TempRepeaterWidget({
    @required this.temperature,
    @required this.parentValueChange,
  });

  @override
  _TempRepeaterWidget createState() => _TempRepeaterWidget();
}

class _TempRepeaterWidget extends State<TempRepeaterWidget> {
  StreamSubscription streamSubscription;

  final _myTextController = new TextEditingController();
  String _lastValidCorrected = "0";
  int parentTemperature;
  int _myValue = 0;

  @override
  void initState() {
    super.initState();
    parentTemperature = widget.temperature;
    streamSubscription = widget.parentValueChange.listen((data) => onParentChange(data));
    _myTextController.addListener(_onInputTextChange);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("Altitude",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Container(
                  width: 80,
                  child: TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5),
                    ],
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.numberWithOptions(),
                    maxLines: 1,
                    controller: _myTextController,
                    autovalidate: true,
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
            padding: EdgeInsets.symmetric(horizontal: 10),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Corrected",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                _correctedTextWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
    streamSubscription.cancel();
  }


  void _onInputTextChange() {
    setState(() {
      _myValue = int.tryParse(_myTextController.text);
    });
  }

  Widget _correctedTextWidget () {
    String corrected = "";
    try {
      corrected = (_myValue * parentTemperature).toString();
      _lastValidCorrected = corrected;
      return Text(
          corrected,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          )
      );
    } catch (e) {
      return Text(
          _lastValidCorrected,
          style: TextStyle(
            color: Colors.red,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          )
      );
    }

  }

  onParentChange(int dataChanged) {
    setState(() {
      parentTemperature = dataChanged;
    });
  }

}