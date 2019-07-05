import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'package:cavokator_flutter/utils/theme_me.dart';
import 'package:cavokator_flutter/condition/condition_decode.dart';
import 'package:cavokator_flutter/utils/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ConditionPage extends StatefulWidget {
  final bool isThemeDark;
  final Widget myFloat;
  final Function callback;

  ConditionPage({@required this.isThemeDark, @required this.myFloat, @required this.callback});

  @override
  _ConditionPageState createState() => _ConditionPageState();
}

class _ConditionPageState extends State<ConditionPage> {
  final _formKey = GlobalKey<FormState>();
  final _myTextController = new TextEditingController();
  String _userConditionInput = "";

  bool _resultsToShow = false;
  Widget _resultsPositive;


  @override
  void initState() {
    super.initState();

    _restoreSharedPreferences();

    // Delayed callback for FAB
    Future.delayed(Duration.zero, () => fabCallback());

  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: CustomScrollView(
            slivers: _buildSlivers(context),
          ),
        );
      },
    );
  }

  Future<void> fabCallback() async {
    widget.callback(SizedBox.shrink());
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = new List<Widget>();

    slivers.add(_myAppBar());
    slivers.add(_inputForm());
    slivers.add(_resultSection());

    return slivers;
  }

  Widget _myAppBar() {
    return SliverAppBar(
      iconTheme: new IconThemeData(color: Colors.white),
      title: Text(
        "Runway Condition",
        style: TextStyle(color: Colors.white),
      ),
      expandedHeight: 150,  // TODO: Settings option (value '0' if inactive)
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/condition_header.jpg'),
              fit: BoxFit.fitWidth,
              colorFilter: widget.isThemeDark == true
                  ? ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken)
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputForm() {
    return CustomSliverSection(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 25),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            border: Border.all(color: Colors.grey),
            color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainBackground)
          //color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      ),
                      ImageIcon(
                        AssetImage("assets/icons/drawer_condition.png"),
                        color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      ),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 24,
                            color: ThemeMe.apply(widget.isThemeDark, DesiredColor.MainText),
                          ),
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          maxLength: 11,
                          controller: _myTextController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(fontSize: 14),
                            labelText: "Enter runway condition",
                          ),
                          validator: (value) {
                            RegExp exp = RegExp(
                                r"((\b)(R)+(\d\d([LCR]?)+(\/)+([0-9]|\/){6})(\b))"
                                r"|((\b)(([0-9]|\/){8})+(\b))"
                                r"|((\b)+(R\/SNOCLO)+(\b))"
                                r"|((\b)+(R\d\d([LCR]?))+(\/)+(CLRD)+(\/\/))",
                                caseSensitive: false);
                            String myMatch = exp
                                .stringMatch(_myTextController.text)
                                .toString();
                            if (myMatch != "null"){
                              _userConditionInput = myMatch;
                            } else {
                              return "Invalid, double check!";
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      ),
                      RaisedButton(
                          child: Text('Decode!'),
                          onPressed: () {
                            _decodeButtonPressed();
                          }),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                      RaisedButton(
                        child: Text('Clear'),
                        onPressed: () {
                          setState(() {
                            _myTextController.text = "";
                            _resultsToShow = false;
                            _clearSharedPreferences();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultSection () {
    if (!_resultsToShow) {
      return CustomSliverSection(
        child: _resultExamples(),
      );
    } else {
      return CustomSliverSection(
        child: _resultsPositive,
      );
    }

  }

  Widget _resultExamples (){
    return Container(
      padding: EdgeInsets.only(left: 50, top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("EXAMPLES",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )
          ),
          Padding(
              padding: EdgeInsets.only(left: 20, top: 20),
              child: Text(
                "R27L/356691" +
                    "\n\n88356691" +
                    "\n\nR27/CLRD//" +
                    "\n\nR/SNOCLO",
                style: TextStyle(
                    fontSize: 18),
              )
          ),
        ],
      ),
    );
  }



  void _decodeButtonPressed() {
    if (_formKey.currentState.validate()) {
      _userConditionInput = _myTextController.text;
      _saveSharedPreferences();
      _decodeCondition();
    }
  }


  void _decodeCondition() {
    var condition = ConditionDecode(conditionString: _userConditionInput);
    ConditionModel decodedCondition = condition.getDecodedCondition;

    if (decodedCondition.error) {
      _resultsPositive = Container(
        padding: EdgeInsets.only(left: 50, top: 30, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("ERROR!"
                "\n\n"
                "Invalid runway condition.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    } else if (decodedCondition.isSnoclo) {
      _resultsPositive = Container(
        padding: EdgeInsets.only(left: 50, top: 30, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Text(
                "SNOCLO",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            Text(
              decodedCondition.snocloDecoded,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else if (decodedCondition.isClrd) {
      _resultsPositive = Container(
        padding: EdgeInsets.only(left: 50, top: 30, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                  decodedCondition.rwyError ?
                  "(runway error)"
                        : "Runway ${decodedCondition.rwyValue}",
                    style: TextStyle(
                      fontSize: decodedCondition.rwyError ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: decodedCondition.rwyError ?
                          Colors.red : null,
                    ),
                  ),
                  Text(
                    " CLEARED",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              decodedCondition.clrdDecoded,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else {
      _resultsPositive = Container(
        padding: EdgeInsets.only(left: 50, top: 30, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Runway
            Padding(
              padding: EdgeInsets.only(top:20),
              child: Row(
                children: <Widget> [
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.rwyCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.rwyDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Deposit type
            Padding(
              padding: EdgeInsets.only(top:20),
              child: Row(
                children: <Widget> [
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.depositCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.depositDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Extent
            Padding(
              padding: EdgeInsets.only(top:20),
              child: Row(
                children: <Widget> [
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.extentCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.extentDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Depth
            Padding(
              padding: EdgeInsets.only(top:20),
              child: Row(
                children: <Widget> [
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.depthCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.depthDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Runway
            Padding(
              padding: EdgeInsets.only(top:20),
              child: Row(
                children: <Widget> [
                  Container(
                    width: 90,
                    child: Text(
                      decodedCondition.frictionCode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        decodedCondition.frictionDecoded,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    setState(() {
      _resultsToShow = true;
    });
  }

  void _saveSharedPreferences() {
    SharedPreferencesModel().setConditionInput(_userConditionInput);
    SharedPreferencesModel().setConditionInput(_myTextController.text);
  }

  void _clearSharedPreferences() {
    SharedPreferencesModel().setConditionInput("");
    SharedPreferencesModel().setConditionInput("");
  }

  void _restoreSharedPreferences() async {
    await SharedPreferencesModel().getConditionModel().then((onValue) {
      setState(() {
        _userConditionInput = onValue;
      });
    });

    await SharedPreferencesModel().getConditionInput().then((onValue) {
      setState(() {
        _myTextController.text = onValue;
      });
    });

    if (_userConditionInput != "" || _myTextController.text != ""){
      _decodeCondition();
    }
  }



}