import 'package:flutter/material.dart';

void main() => runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: new ThemeData(primarySwatch: Colors.blueGrey),
    home: new WeatherPage()));

class WeatherPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                leading: ImageIcon(AssetImage("assets/icons/drawer_wx.png")),
                title: Text('Weather'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('NOTAM'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(title: new Text("Weather")),
        body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: WeatherSubmitForm(),
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode())));
  }
}

class WeatherSubmitForm extends StatefulWidget {
  @override
  _WeatherSubmitFormState createState() => _WeatherSubmitFormState();
}

class _WeatherSubmitFormState extends State<WeatherSubmitForm> {
  final _formKey = GlobalKey<FormState>();
  final _myTextController = new TextEditingController();

  String _myCurrentSubmitText;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(children: [
                    Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                    ImageIcon(AssetImage("assets/icons/drawer_wx.png")),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 20, 0)),
                    Expanded(
                      child: TextFormField(
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          controller: _myTextController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                              hintText: "Enter ICAO/IATA airports"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please enter at least one valid airport!";
                            }
                          }))
                  ]),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  RaisedButton(
                      child: Text('Fetch WX!'),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Processing Data')));
                        }
                        FocusScope.of(context).requestFocus(new FocusNode());
                      })
                ])));
  }

  @override
  void initState() {
    super.initState();

    _myCurrentSubmitText = _myTextController.text;
    _myTextController.addListener(onSubmitTextChange);
  }

  // Ensure that submitted airports are split correctly
  void onSubmitTextChange() {
    String textEntered = _myTextController.text;
    // Don't do anything if we are deleting text!
    if (textEntered.length > _myCurrentSubmitText.length) {
      if (textEntered.length > 3) {
        // Take a look at the last 4 chars entered
        String lastFourChars =
            textEntered.substring(textEntered.length - 4, textEntered.length);
        // If there is at least a space, do nothing
        bool lala = true;
        for (String char in lastFourChars.split("")) {
          if (char == " ") {
            lala = false;
          }
        }
        if (lala) {
          _myTextController.text = textEntered + " ";
          _myTextController.selection = TextSelection.fromPosition(
              TextPosition(offset: _myTextController.text.length));
        }
      }
    }
    _myCurrentSubmitText = textEntered;
  }
}
