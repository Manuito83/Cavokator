import 'package:cavokator_flutter/json_models/wx_json.dart';

class WxModelList {
  var wxModelList = <WxModel>[];
}

class WxModel {
  String? airportHeading;
  var airportWeather = <AirportWeather>[];
  late bool airportFound;
}

abstract class AirportWeather {}

class AirportMetar extends AirportWeather {
  List<String?> metars = <String>[];
}

class AirportTafor extends AirportWeather {
  var tafors = <String>[];
}

class MetarTimes extends AirportWeather {
  var metarTimes = <DateTime>[];
  String? metarTimesId;
  bool error = false;
}

class TaforTimes extends AirportWeather {
  var taforTimes = <DateTime>[];
  bool error = false;
}

class WxItemBuilder {
  var jsonWeatherList = <WxJson>[];
  var result = WxModelList();

  WxItemBuilder({required this.jsonWeatherList}) {
    // Iterate every airport inside of list
    for (var i = 0; i < jsonWeatherList.length; i++) {
      var wxModel = WxModel();
      var _myMetarsTimes = MetarTimes();
      var _myMetars = AirportMetar();
      var _myTaforsTimes = TaforTimes();
      var _myTafors = AirportTafor();

      for (var mets in jsonWeatherList[i].metars!) {
        // Time
        if (mets.metarTime != null) {
          final timeString = mets.metarTime!;
          final thisTime = DateTime.parse(timeString).toUtc();
          _myMetarsTimes.metarTimes.add(thisTime);
          _myMetarsTimes.metarTimesId = jsonWeatherList[i].airportIdIcao;
        } else {
          _myMetarsTimes.error = true;
        }
        // Metar
        if (mets.metar == null || mets.metar == "") {
          _myMetars.metars.add("No METAR found!");
        } else {
          _myMetars.metars.add(mets.metar);
        }
      }

      for (var tafs in jsonWeatherList[i].tafors!) {
        // Time
        if (tafs.taforTime != null) {
          final timeString = tafs.taforTime!;
          final thisTime = DateTime.parse(timeString).toUtc();
          _myTaforsTimes.taforTimes.add(thisTime);
        } else {
          _myTaforsTimes.error = true;
        }
        // Tafor
        if (tafs.tafor == null || tafs.tafor == "") {
          _myTafors.tafors.add("No TAFOR found!");
        } else {
          _myTafors.tafors.add(tafs.tafor!);
        }
      }

      if (jsonWeatherList[i].airportNotFound!) {
        wxModel.airportFound = false;
      } else {
        wxModel.airportFound = true;
      }

      wxModel.airportHeading = jsonWeatherList[i].fullAirportDetails!.name;
      wxModel.airportWeather.add(_myMetarsTimes);
      wxModel.airportWeather.add(_myMetars);
      wxModel.airportWeather.add(_myTaforsTimes);
      wxModel.airportWeather.add(_myTafors);

      result.wxModelList.add(wxModel);
    }
  }
}
