import 'package:flutter/material.dart';
import 'package:cavokator_flutter/utils/custom_sliver.dart';
import 'dart:async';
import 'package:cavokator_flutter/utils/shared_prefs.dart';

class FavouritesPage extends StatefulWidget {
  final bool isThemeDark;
  final Widget myFloat;
  final Function callback;

  FavouritesPage({@required this.isThemeDark, @required this.myFloat,
                @required this.callback});

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {

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
    slivers.add(_topSearch());

    return slivers;
  }

  Widget _myAppBar() {
    return SliverAppBar(
      title: Text("Favourites"),
      pinned: true,
    );
  }

  Widget _topSearch () {
    return CustomSliverSection(
      child: Container (
        child: Column (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding (
              padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text (
                      "SEARCH BAR",
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RawMaterialButton (
                    shape: new CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.grey,
                    child: Icon(Icons.add),
                    onPressed: () {
                      // TODO: https://medium.com/@excogitatr/custom-dialog-in-flutter-d00e0441f1d5
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _restoreSharedPreferences() async {
    await SharedPreferencesModel().getSettingsOpenSpecificSection().then((onValue) {
      setState(() {
        // TODO
      });
    });

  }

}