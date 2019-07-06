import 'package:cavokator_flutter/json_models/notam_json.dart';

class NotamModelList {
  var notamModelList = List<NotamModel>();
}

class NotamModel {
  String airportHeading;
  String airportCode; // Not using this for anything at the moment
  var airportNotams = List<NotamGeneric>();

  bool airportWithNoNotam = false;
  bool airportNotFound = false;
}

abstract class NotamGeneric {}

class NotamCategory extends NotamGeneric {
  String mainCategory;
}

class NotamSingle extends NotamGeneric {
  bool notamQ;
    // Top categories
  String mainCategory;
  // Notam ID
  String id;
  // NOTAM categories (per NOTAM)
  String categorySubMain;
  String categorySubSecondary;
  // NOTAM text
  String freeText;
  // Whole NOTAM (shown when clicked on the ID)
  String raw;
  // Position for map
  double latitude;
  double longitude;
  int radius;
  // Times and dates
  DateTime startTime;
  DateTime endTime;
  bool estimated;
  bool permanent;
  // Valid Times
  String validTimes;
  // Top and bottom limits
  String topLimit;
  String bottomLimit;

}

class NotamItemBuilder {
  var jsonNotamList = List<NotamJson>();
  bool sortCategories;
  var result = NotamModelList();

  NotamItemBuilder({ this.jsonNotamList, this.sortCategories }) {
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
        var finalNotamItemList = List<AirportNotam>();
        if (sortCategories){
          // Find out which categories are here
          var categoryW = List<int>();
          var categoryL = List<int>();
          var categoryM = List<int>();
          var categoryF = List<int>();
          var categoryA = List<int>();
          var categoryS = List<int>();
          var categoryP = List<int>();
          var categoryC = List<int>();
          var categoryI = List<int>();
          var categoryG = List<int>();
          var categoryN = List<int>();
          var categoryR = List<int>();
          var categoryO = List<int>();
          var categoryNotReported = List<int>();
          var noNotamQ = List<int>();

          for (var n = 0; n < jsonNotamList[i].airportNotam.length; n++) {
            var currentNotamCategory = jsonNotamList[i].airportNotam[n].categoryPrimary;
            if (!jsonNotamList[i].airportNotam[n].notamQ) {
              noNotamQ.add(n);
            } else if (currentNotamCategory == "Warnings") {
              categoryW.add(n);
            } else if (currentNotamCategory == "Lighting facilities") {
              categoryL.add(n);
            } else if (currentNotamCategory == "Movement and landing area") {
              categoryM.add(n);
            } else if (currentNotamCategory == "Facilities and services") {
              categoryF.add(n);
            } else if (currentNotamCategory == "Airspace organization") {
              categoryA.add(n);
            } else if (currentNotamCategory == "Air traffic and VOLMET") {
              categoryS.add(n);
            } else if (currentNotamCategory == "Air traffic procedures") {
              categoryP.add(n);
            } else if (currentNotamCategory == "Communications and surveillance") {
              categoryC.add(n);
            } else if (currentNotamCategory == "Instrument landing system") {
              categoryI.add(n);
            } else if (currentNotamCategory == "GNSS services") {
              categoryG.add(n);
            } else if (currentNotamCategory == "Terminal and en-route navaids") {
              categoryN.add(n);
            } else if (currentNotamCategory == "Airspace restrictions") {
              categoryR.add(n);
            } else if (currentNotamCategory == "Other information") {
              categoryO.add(n);
            } else {
              categoryNotReported.add(n);
            }
          }

          var sortedNotamList = List<AirportNotam>();
          for (var sorted in categoryW) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryL) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryM) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryF) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryA) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryS) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryP) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryC) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryI) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryG) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryN) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryR) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryO) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in categoryNotReported) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }
          for (var sorted in noNotamQ) {
            sortedNotamList.add(jsonNotamList[i].airportNotam[sorted]);
          }

          finalNotamItemList = sortedNotamList;

        } else {
          finalNotamItemList = jsonNotamList[i].airportNotam;
        }

        // We will compare against this variable
        var currentCategory = "";

        for (var j = 0; j < finalNotamItemList.length; j++) {

          var categoryToBeAdded = NotamCategory();

          // We are adding a name in case there is no category
          if (finalNotamItemList[j].categoryPrimary == "") {
            finalNotamItemList[j].categoryPrimary = "(no category)";
          }

          if (!finalNotamItemList[j].notamQ) {
            finalNotamItemList[j].categoryPrimary = "(raw)";
          }


          if (finalNotamItemList[j].categoryPrimary != currentCategory) {
            currentCategory = finalNotamItemList[j].categoryPrimary;
            categoryToBeAdded.mainCategory = finalNotamItemList[j].categoryPrimary;
            notamModel.airportNotams.add(categoryToBeAdded);
          }

          var _thisNotam = NotamSingle();

          if (finalNotamItemList[j].notamQ) {
            _thisNotam.notamQ = true;
            _thisNotam.mainCategory = finalNotamItemList[j].categoryPrimary;
            _thisNotam.id = finalNotamItemList[j].notamId;
            _thisNotam.categorySubMain = finalNotamItemList[j].categorySubMain;
            _thisNotam.categorySubSecondary = finalNotamItemList[j].categorySubSecondary;
            _thisNotam.freeText = finalNotamItemList[j].notamFreeText;
            _thisNotam.raw = finalNotamItemList[j].notamRaw;
            _thisNotam.latitude = finalNotamItemList[j].latitude;
            _thisNotam.longitude = finalNotamItemList[j].longitude;
            _thisNotam.radius = finalNotamItemList[j].radius;

            // Dates
            String myStartString = finalNotamItemList[j].startTime;
            _thisNotam.startTime = DateTime.tryParse(myStartString);

            // Be careful, a the API passes DateTime.maxValue if Permanent
            _thisNotam.estimated = finalNotamItemList[j].endTimeEstimated;
            _thisNotam.permanent = finalNotamItemList[j].endTimePermanent;
            if (!_thisNotam.permanent) {
              String myEndString = finalNotamItemList[j].endTime;
              _thisNotam.endTime = DateTime.tryParse(myEndString);
            } else {
              _thisNotam.endTime = null;
            }

            // Times
            _thisNotam.validTimes = finalNotamItemList[j].spanTime;

            // Limits
            _thisNotam.topLimit = finalNotamItemList[j].topLimit;
            _thisNotam.bottomLimit = finalNotamItemList[j].bottomLimit;
          } else {
            _thisNotam.notamQ = false;
            _thisNotam.raw = finalNotamItemList[j].notamRaw;
          }

          notamModel.airportNotams.add(_thisNotam);
        }
      }
      else {
        // TODO: no notams!
      }

      notamModel.airportHeading = jsonNotamList[i].fullAirportDetails.name;

      jsonNotamList[i].airportIdIata == "" ?
        notamModel.airportCode = jsonNotamList[i].airportIdIcao :
        notamModel.airportCode = jsonNotamList[i].airportIdIata;

      result.notamModelList.add(notamModel);
    }
  }
}


