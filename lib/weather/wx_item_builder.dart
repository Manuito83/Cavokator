import 'package:cavokator_flutter/json_models/wx_json.dart';

abstract class WxItems {}

class AirportHeading implements WxItems {
  final String name;

  AirportHeading(this.name);
}

class AirportBody implements WxItems {
  var metars = List<String>();
  var tafors = List <String>();

  AirportBody(this.metars, this.tafors);
}

class WxItemBuilder {
  var wxItems = List<WxItems>();
  var jsonWeatherList = List<WxJson>();

  WxItemBuilder({ this.jsonWeatherList }){
    // Iterate every airport inside of list
    for (var item in jsonWeatherList){
      wxItems.add(AirportHeading(item.fullAirportDetails.name));

      var myMets = List<String>();
      myMets.add(item.metars[0].metar);

      // TODO: delete, just for testing scrollview!
      for (var i = 0; i < 100; i++){
        myMets.add(item.metars[0].metar);
      }

      var myTafs = List<String>();
      myTafs.add(item.tafors[0].tafor);

      wxItems.add(AirportBody(myMets, myTafs));
    }
  }

}