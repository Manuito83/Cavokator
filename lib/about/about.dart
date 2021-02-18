import 'dart:io';

import 'package:cavokator_flutter/utils/changelog.dart';
import 'package:cavokator_flutter/utils/hyperlink.dart';
import 'package:flutter/material.dart';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'dart:async';
import 'package:cavokator_flutter/main.dart';

class AboutPage extends StatefulWidget {
  final bool isThemeDark;
  final Widget myFloat;
  final Function callback;
  final String thisAppVersion;

  AboutPage({@required this.isThemeDark, @required this.myFloat,
    @required this.callback, @required this.thisAppVersion});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  @override
  void initState() {
    super.initState();

    // Delayed callback for FAB
    Future.delayed(Duration.zero, () => fabCallback());
  }

  Future<void> fabCallback() async {
    widget.callback(SizedBox.shrink());
  }

  Widget _myAppBar() {
    return SliverAppBar(
      title: Text("What's this about?"),
      pinned: true,
    );
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


  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = new List<Widget>();

    slivers.add(_myAppBar());
    slivers.add(_aboutBody());

    return slivers;
  }


  Widget _aboutBody () {
    return CustomSliverSection(
      child: Container (
        child: Column (
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(30,50,30,0),
              child: Image(
                image: AssetImage('assets/images/appicon.png'),
                height: 200,
                fit: BoxFit.fill,
              ),
            ),
            Text(
              "CAVOKATOR",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding (
              padding: EdgeInsets.fromLTRB(30, 25, 30, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Flexible (
                    child: Text(
                      "Cavokator is a free application made by pilots, "
                          "for pilots, with the only goal of offering "
                          "quick and simple information.",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            /*
            Padding (
              padding: EdgeInsets.fromLTRB(50, 25, 30, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Flexible (
                    child: Text(
                      "Contact: ",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Flexible (
                    child: Hyperlink(
                        'mailto:info@cavokator.com',
                        'info@cavokator.com'),
                  ),
                ],
              ),
            ),
            */
            Padding (
              padding: EdgeInsets.fromLTRB(50, 10, 30, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Flexible (
                    child: Text(
                      "Changelog: ",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Flexible (
                    child: InkWell(
                      child: Text(
                        "click here to view",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                      onTap: _showChangeLogDialog,
                    ),
                  ),
                ],
              ),
            ),
            Padding (
              padding: EdgeInsets.fromLTRB(50, 10, 30, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Flexible (
                    child: Text(
                      "Version: $thisAppVersion (${Platform.isAndroid ? androidVersionCode : iosVersionCode})",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 40, 0, 5),
              child: Divider(),
            ),
            Padding (
              padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Flexible (
                    child: Text(
                      "WARNING: Cavokator was not certified for in-flight"
                          " use, please do not it for real in-flight operations or"
                          " do so under your own responsability. There might"
                          " be errors and the information shown might not be"
                          " complete of outdated.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeLogDialog() {
    showDialog (
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (context) {
          return ChangeLog(appVersion: widget.thisAppVersion);
        }
    );
  }

}