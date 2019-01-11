import 'package:cavokator_flutter/json_models/wx_json.dart';

class WxInfoModelList
{
  var wxInfoList = List<WxInfoModel>();
}

class WxInfoModel {
  String airportHeading;
  var airportWeatherList = List <AirportWeather>();
}

abstract class AirportWeather {}

class AirportMetar extends AirportWeather {
  List<String> metarList = new List<String>();
}

class AirportTafor extends AirportWeather {
  List<String> taforList = new List<String>();
}

class AirportTime extends AirportWeather {
  DateTime weatherTime = new DateTime.now().toUtc();
}



class WxItemBuilder {

  var jsonWeatherList = List<WxJson>();
  var result = WxInfoModelList();

  WxItemBuilder({ this.jsonWeatherList }){

    // Iterate every airport inside of list
    for (var i = 0; i < jsonWeatherList.length; i++){
      var wxModel = WxInfoModel();
      var _myMetars = AirportMetar();
      var _myTafors = AirportTafor();

      for (var mets in jsonWeatherList[i].metars){
        _myMetars.metarList.add(mets.metar);
      }

      for (var tafs in jsonWeatherList[i].tafors){
        _myTafors.taforList.add(tafs.tafor);
      }

      wxModel.airportHeading = jsonWeatherList[i].fullAirportDetails.name;
      wxModel.airportWeatherList.add(_myMetars);
      wxModel.airportWeatherList.add(_myTafors);

      result.wxInfoList.add(wxModel);
    }
  }
}