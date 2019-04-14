import 'package:cavokator_flutter/json_models/notam_json.dart';

class NotamModelList {
  var notamModelList = List<NotamModel>();
}

class NotamModel {
  String airportHeading;
  var airportNotams = List<AirportNotam>();

  bool airportWithNoNotam = false;
  bool airportNotFound = false;
}

class AirportNotam {
  String id;
  String freeText;
  String raw;
}

class NotamItemBuilder {
  var jsonNotamList = List<NotamJson>();
  var result = NotamModelList();

  NotamItemBuilder({ this.jsonNotamList }) {
    // Iterate every airport inside of list
    for (var i = 0; i < jsonNotamList.length; i++) {
      var notamModel = NotamModel();

      if (jsonNotamList[i].airportNotFound) {
        notamModel.airportNotFound = true;
      }
      else if (jsonNotamList[i].airportWithNoNotam) {
        notamModel.airportWithNoNotam = true;
      }
      else if (jsonNotamList[i].notamCount > 0) {
        for (var j = 0; j < jsonNotamList[i].airportNotam.length; j++) {
          var _thisNotam = AirportNotam();
          _thisNotam.id = jsonNotamList[i].airportNotam[j].notamId;
          _thisNotam.freeText = jsonNotamList[i].airportNotam[j].notamFreeText;
          _thisNotam.raw = jsonNotamList[i].airportNotam[j].notamRaw;

          notamModel.airportNotams.add(_thisNotam);
        }
      }
      else {
        // TODO: no notams!
      }

      notamModel.airportHeading = jsonNotamList[i].fullAirportDetails.name;
      result.notamModelList.add(notamModel);
    }
  }
}


