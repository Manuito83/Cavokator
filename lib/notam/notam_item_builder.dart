import 'package:cavokator_flutter/json_models/notam_json.dart';

class NotamModelList {
  var notamModelList = List<NotamModel>();
}

class NotamModel {
  String airportHeading;
  var airportNotams = List<AirportNotam>();
}

class AirportNotam {
  String Id;
  String freeText;
}

class NotamItemBuilder {
  var jsonNotamList = List<NotamJson>();
  var result = NotamModelList();

  NotamItemBuilder({ this.jsonNotamList }) {
    // Iterate every airport inside of list
    for (var i = 0; i < jsonNotamList.length; i++) {
      var notamModel = NotamModel();

      for (var j = 0; j < jsonNotamList[i].airportNotam.length; j++) {
        var _thisNotam = AirportNotam();
        _thisNotam.Id = jsonNotamList[i].airportNotam[j].notamId;
        _thisNotam.freeText = jsonNotamList[i].airportNotam[j].notamFreeText;

        notamModel.airportNotams.add(_thisNotam);
      }
      
      notamModel.airportHeading = jsonNotamList[i].fullAirportDetails.name;
      result.notamModelList.add(notamModel);
    }
  }
}


