import 'package:cavokator_flutter/json_models/wx_json.dart';

class WxInfoModel {
  var airportList = List<AirportHeading>();
  var weatherList = List <AirportWeather>();
}

class AirportHeading {
  final String name;

  AirportHeading(this.name);
}

class AirportWeather {
  var metars = List<String>();
  var tafors = List <String>();

  AirportWeather(this.metars, this.tafors);
}

class WxItemBuilder {

  var wxModel = WxInfoModel();
  var jsonWeatherList = List<WxJson>();
  var _myAirports = List<AirportHeading>();
  var _myWeathers = List<AirportWeather>();

  WxItemBuilder({ this.jsonWeatherList }){
    // Iterate every airport inside of list
    for (var item in jsonWeatherList){
      _myAirports.add(AirportHeading(item.fullAirportDetails.name));

      var mets = List<String>();
      mets.add(item.metars[0].metar);

      // TODO: delete, just for testing scrollview!
      for (var i = 0; i < 20; i++){
        mets.add(item.metars[0].metar);
      }

      var tafs = List<String>();
      tafs.add(item.tafors[0].tafor);

      _myWeathers.add(AirportWeather(mets, tafs));
    }
    wxModel = WxInfoModel();
    wxModel.airportList = _myAirports;
    wxModel.weatherList = _myWeathers;
  }

}