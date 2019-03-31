// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<NotamJson> notamJsonFromJson(String str) {
  final jsonData = json.decode(str);
  return new List<NotamJson>.from(jsonData.map((x) => NotamJson.fromJson(x)));
}

String welcomeToJson(List<NotamJson> data) {
  final dyn = new List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}

class NotamJson {
  String airportIdIcao;
  String airportIdIata;
  List<AirportNotam> airportNotam;
  FullAirportDetails fullAirportDetails;
  int notamCount;
  bool airportWithNoNotam;
  bool airportNotFound;

  NotamJson({
    this.airportIdIcao,
    this.airportIdIata,
    this.airportNotam,
    this.fullAirportDetails,
    this.notamCount,
    this.airportWithNoNotam,
    this.airportNotFound,
  });

  factory NotamJson.fromJson(Map<String, dynamic> json) => new NotamJson(
    airportIdIcao: json["AirportIdIcao"],
    airportIdIata: json["AirportIdIata"],
    airportNotam: new List<AirportNotam>.from(json["AirportNotam"].map((x) => AirportNotam.fromJson(x))),
    fullAirportDetails: FullAirportDetails.fromJson(json["FullAirportDetails"]),
    notamCount: json["NotamCount"],
    airportWithNoNotam: json["AirportWithNoNotam"],
    airportNotFound: json["AirportNotFound"],
  );

  Map<String, dynamic> toJson() => {
    "AirportIdIcao": airportIdIcao,
    "AirportIdIata": airportIdIata,
    "AirportNotam": new List<dynamic>.from(airportNotam.map((x) => x.toJson())),
    "FullAirportDetails": fullAirportDetails.toJson(),
    "NotamCount": notamCount,
    "AirportWithNoNotam": airportWithNoNotam,
    "AirportNotFound": airportNotFound,
  };
}

class AirportNotam {
  String notamId;
  bool notamQ;
  bool notamD;
  String categoryPrimary;
  String categorySubMain;
  String categorySubSecondary;
  String startTime;
  String endTime;
  bool endTimeEstimated;
  bool endTimePermanent;
  String spanTime;
  String bottomLimit;
  String topLimit;
  double latitude;
  double longitude;
  int radius;
  String notamFreeText;
  String notamRaw;

  AirportNotam({
    this.notamId,
    this.notamQ,
    this.notamD,
    this.categoryPrimary,
    this.categorySubMain,
    this.categorySubSecondary,
    this.startTime,
    this.endTime,
    this.endTimeEstimated,
    this.endTimePermanent,
    this.spanTime,
    this.bottomLimit,
    this.topLimit,
    this.latitude,
    this.longitude,
    this.radius,
    this.notamFreeText,
    this.notamRaw,
  });

  factory AirportNotam.fromJson(Map<String, dynamic> json) => new AirportNotam(
    notamId: json["NotamId"],
    notamQ: json["NotamQ"],
    notamD: json["NotamD"],
    categoryPrimary: json["CategoryPrimary"],
    categorySubMain: json["CategorySubMain"],
    categorySubSecondary: json["CategorySubSecondary"],
    startTime: json["StartTime"],
    endTime: json["EndTime"],
    endTimeEstimated: json["EndTimeEstimated"],
    endTimePermanent: json["EndTimePermanent"],
    spanTime: json["SpanTime"],
    bottomLimit: json["BottomLimit"],
    topLimit: json["TopLimit"],
    latitude: json["Latitude"].toDouble(),
    longitude: json["Longitude"].toDouble(),
    radius: json["Radius"],
    notamFreeText: json["NotamFreeText"],
    notamRaw: json["NotamRaw"],
  );

  Map<String, dynamic> toJson() => {
    "NotamId": notamId,
    "NotamQ": notamQ,
    "NotamD": notamD,
    "CategoryPrimary": categoryPrimary,
    "CategorySubMain": categorySubMain,
    "CategorySubSecondary": categorySubSecondary,
    "StartTime": startTime,
    "EndTime": endTime,
    "EndTimeEstimated": endTimeEstimated,
    "EndTimePermanent": endTimePermanent,
    "SpanTime": spanTime,
    "BottomLimit": bottomLimit,
    "TopLimit": topLimit,
    "Latitude": latitude,
    "Longitude": longitude,
    "Radius": radius,
    "NotamFreeText": notamFreeText,
    "NotamRaw": notamRaw,
  };
}

class FullAirportDetails {
  String id;
  String ident;
  String type;
  String name;
  String latitudeDeg;
  String longitudeDeg;
  String elevationFt;
  String continent;
  String isoCountry;
  String isoRegion;
  String municipality;
  String scheduledService;
  String gpsCode;
  String iataCode;
  String localCode;
  String homeLink;
  String wikipediaLink;
  String keywords;

  FullAirportDetails({
    this.id,
    this.ident,
    this.type,
    this.name,
    this.latitudeDeg,
    this.longitudeDeg,
    this.elevationFt,
    this.continent,
    this.isoCountry,
    this.isoRegion,
    this.municipality,
    this.scheduledService,
    this.gpsCode,
    this.iataCode,
    this.localCode,
    this.homeLink,
    this.wikipediaLink,
    this.keywords,
  });

  factory FullAirportDetails.fromJson(Map<String, dynamic> json) => new FullAirportDetails(
    id: json["id"],
    ident: json["ident"],
    type: json["type"],
    name: json["name"],
    latitudeDeg: json["latitude_deg"],
    longitudeDeg: json["longitude_deg"],
    elevationFt: json["elevation_ft"],
    continent: json["continent"],
    isoCountry: json["iso_country"],
    isoRegion: json["iso_region"],
    municipality: json["municipality"],
    scheduledService: json["scheduled_service"],
    gpsCode: json["gps_code"],
    iataCode: json["iata_code"],
    localCode: json["local_code"],
    homeLink: json["home_link"],
    wikipediaLink: json["wikipedia_link"],
    keywords: json["keywords"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ident": ident,
    "type": type,
    "name": name,
    "latitude_deg": latitudeDeg,
    "longitude_deg": longitudeDeg,
    "elevation_ft": elevationFt,
    "continent": continent,
    "iso_country": isoCountry,
    "iso_region": isoRegion,
    "municipality": municipality,
    "scheduled_service": scheduledService,
    "gps_code": gpsCode,
    "iata_code": iataCode,
    "local_code": localCode,
    "home_link": homeLink,
    "wikipedia_link": wikipediaLink,
    "keywords": keywords,
  };
}
