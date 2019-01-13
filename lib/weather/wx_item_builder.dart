import 'package:cavokator_flutter/json_models/wx_json.dart';

class WxModelList
{
  var wxModelList = List<WxModel>();
}

class WxModel {
  String airportHeading;
  var airportWeather = List <AirportWeather>();
}

abstract class AirportWeather {}

class AirportMetar extends AirportWeather {
  List<String> metars = new List<String>();
}

class AirportTafor extends AirportWeather {
  var tafors = new List<String>();
}

class MetarTimes extends AirportWeather {
  var metarTimes = List<DateTime>();
  bool error = false;
}

class TaforTimes extends AirportWeather {
  var taforTimes = List<DateTime>();
  bool error;
}

class WxItemBuilder {

  var jsonWeatherList = List<WxJson>();
  var result = WxModelList();

  WxItemBuilder({ this.jsonWeatherList }){

    // Iterate every airport inside of list
    for (var i = 0; i < jsonWeatherList.length; i++){
      var wxModel = WxModel();
      var _myMetarsTimes = MetarTimes();
      var _myMetars = AirportMetar();
      var _myTaforsTimes = TaforTimes();
      var _myTafors = AirportTafor();

      for (var mets in jsonWeatherList[i].metars){
        // Time
        if (mets.metarTime != null){
          final timeString = mets.metarTime;
          final thisTime = DateTime.parse(timeString).toUtc();
          _myMetarsTimes.metarTimes.add(thisTime);
        } else {
          _myMetarsTimes.error = true;
        }
        // Metar
        _myMetars.metars.add(mets.metar);
      }

      for (var tafs in jsonWeatherList[i].tafors){
        // Time
        if (tafs.taforTime != null){
          final timeString = tafs.taforTime;
          final thisTime = DateTime.parse(timeString).toUtc();
          _myTaforsTimes.taforTimes.add(thisTime);
        } else {
          _myTaforsTimes.error = true;
        }
        // Tafor
        _myTafors.tafors.add(tafs.tafor);
      }

      wxModel.airportHeading = jsonWeatherList[i].fullAirportDetails.name;
      wxModel.airportWeather.add(_myMetarsTimes);
      wxModel.airportWeather.add(_myMetars);
      wxModel.airportWeather.add(_myTaforsTimes);
      wxModel.airportWeather.add(_myTafors);

      result.wxModelList.add(wxModel);
    }
  }
}