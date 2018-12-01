import 'package:flutter/material.dart';

void main() =>
    runApp(new MaterialApp(
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
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
          title: new Text("Weather")
      ),
      body: WeatherSubmitForm(),
    );
  }
}

class WeatherSubmitForm extends StatefulWidget {
  @override
  _WeatherSubmitFormState createState() => _WeatherSubmitFormState();
}

class _WeatherSubmitFormState extends State<WeatherSubmitForm> {
  final _formKey = GlobalKey<FormState>();
  final _myTextController = new TextEditingController();

  final _mySubmitTextInitialCharNumbers = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _myTextController,
              decoration: InputDecoration(
                hintText: "Enter ICAO/IATA airports"),
              validator: (value) {
                if (value.isEmpty){
                  return "Please enter at least one valid airport!";
                }
              }
            ),
            Padding (
              padding: EdgeInsets.all(10),
            ),
            RaisedButton(
              child: Text('Fetch WX!'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                }
                FocusScope.of(context).requestFocus(new FocusNode());
              }
            )
          ]
        )
      )
    );
  }

  @override
  void initState (){
    super.initState();

    // Assign any value that was previously stored (in preferences)
    if (_mySubmitTextInitialCharNumbers.isNotEmpty){
      _myTextController.text = _mySubmitTextInitialCharNumbers;
    }

    _myTextController.addListener(onSubmitTextChange);
  }

  void onSubmitTextChange(){
    String textEntered = _myTextController.text;

    if (textEntered.length > _mySubmitTextInitialCharNumbers.length){
      // TODO: seguir aquí!
    }

  }

}


