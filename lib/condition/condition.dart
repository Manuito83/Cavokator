import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'package:cavokator_flutter/utils/theme_me.dart';
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
  String _userConditionInput;

  @override
  void initState() {
    super.initState();

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
      expandedHeight: 150,
      // TODO: Settings option (value '0' if inactive)
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/condition_header.jpg'),
              fit: BoxFit.fitWidth,
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
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      ),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
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
                                r"((R)+(\d\d([LCR]?)+(\/)+([0-9]|\/){6}))|" +
                                r"((([0-9]|\/){8}))|" +
                                r"((R\/SNOCLO))|" +
                                r"((R\d\d([LCR]?)+(\/)+(CLRD)+(\/\/)))",
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
    return CustomSliverSection(
      child: Container(
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


      ),
    );
  }


  void _decodeButtonPressed() {
    if (_formKey.currentState.validate()) {
      print("BUUU: " + _userConditionInput);
    }

  }

}