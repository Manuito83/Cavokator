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
    airportIdIcao: json["AirportIdIcao"] == null ? null : json["AirportIcao"],
    airportIdIata: json["AirportIdIata"] == null ? null : json["AirportIata"],
    airportNotam: json["AirportNotam"] == null ? null : new List<AirportNotam>.from(json["AirportNotam"].map((x) => AirportNotam.fromJson(x))),
    fullAirportDetails: json["FullAirportDetails"] == null ? null: FullAirportDetails.fromJson(json["FullAirportDetails"]),
    notamCount: json["NotamCount"]  == null ? null : json["NotamCount"],
    airportWithNoNotam: json["AirportWithNoNotam"] == null ? null : json["AirportWithNoNotam"],
    airportNotFound: json["AirportNotFound"] == null ? null : json["AirportNotFound"],
  );

  Map<String, dynamic> toJson() => {
    "AirportIdIcao": airportIdIcao == null ? null : airportIdIcao,
    "AirportIdIata": airportIdIata == null ? null : airportIdIata,
    "AirportNotam": airportNotam == null ? null : new List<dynamic>.from(airportNotam.map((x) => x.toJson())),
    "FullAirportDetails": fullAirportDetails == null ? null : fullAirportDetails.toJson(),
    "NotamCount": notamCount  == null ? null : notamCount,
    "AirportWithNoNotam": airportWithNoNotam == null ? null : airportWithNoNotam,
    "AirportNotFound": airportNotFound == null ? null : airportNotFound,
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
    notamId: json["NotamId"] == null ? null : json["NotamId"],
    notamQ: json["NotamQ"] == null ? null : json["NotamQ"],
    notamD: json["NotamD"] == null ? null : json["NotamD"],
    categoryPrimary: json["CategoryPrimary"] == null ? null : json["CategoryPrimary"],
    categorySubMain: json["CategorySubMain"] == null ? null : json["CategorySubMain"],
    categorySubSecondary: json["CategorySubSecondary"] == null ? null : json["CategorySubSecondary"],
    startTime: json["StartTime"] == null ? null : json["StartTime"],
    endTime: json["EndTime"] == null ? null : json["EndTime"],
    endTimeEstimated: json["EndTimeEstimated"] == null ? null : json["EndTimeEstimated"],
    endTimePermanent: json["EndTimePermanent"] == null ? null : json["EndTimePermanent"],
    spanTime: json["SpanTime"] == null ? null : json["SpanTime"],
    bottomLimit: json["BottomLimit"] == null ? null : json["BottomLimit"],
    topLimit: json["TopLimit"] == null ? null : json["TopLimit"],
    latitude: json["Latitude"] == null ? null : json["Latitude"].toDouble(),
    longitude: json["Longitude"] == null ? null: json["Longitude"].toDouble(),
    radius: json["Radius"] == null ? null : json["Radius"],
    notamFreeText: json["NotamFreeText"] == null ? null : json["NotamFreeText"],
    notamRaw: json["NotamRaw"] == null ? null : json["NotamRaw"],
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
    id: json["id"] == null ? null : json["Id"],
    ident: json["ident"] == null ? null : json["ident"],
    type: json["type"] == null ? null : json["type"],
    name: json["name"] == null ? null : json["name"],
    latitudeDeg: json["latitude_deg"] == null ? null : json["latitude_deg"],
    longitudeDeg: json["longitude_deg"] == null ? null : json["longitude_deg"],
    elevationFt: json["elevation_ft"] == null ? null : json["elevation_ft"],
    continent: json["continent"] == null ? null : json["continent"],
    isoCountry: json["iso_country"] == null ? null : json["iso_country"],
    isoRegion: json["iso_region"] == null ? null : json["iso_region"],
    municipality: json["municipality"] == null ? null : json["municipality"],
    scheduledService: json["scheduled_service"] == null ? null : json["scheduled_service"],
    gpsCode: json["gps_code"] == null ? null : json["gps_code"],
    iataCode: json["iata_code"] == null ? null : json["iata_code"],
    localCode: json["local_code"] == null ? null : json["local_code"],
    homeLink: json["home_link"] == null ? null : json["home_link"],
    wikipediaLink: json["wikipedia_link"] == null ? null : json["wikipedia_link"],
    keywords: json["keywords"] == null ? null : json["keywords"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "ident": ident == null ? null : ident,
    "type": type == null ? null : type,
    "name": name == null ? null : name,
    "latitude_deg": latitudeDeg == null ? null : latitudeDeg,
    "longitude_deg": longitudeDeg == null ? null : longitudeDeg,
    "elevation_ft": elevationFt == null ? null : elevationFt,
    "continent": continent == null ? null : continent,
    "iso_country": isoCountry == null ? null : isoCountry,
    "iso_region": isoRegion == null ? null : isoRegion,
    "municipality": municipality == null ? null : municipality,
    "scheduled_service": scheduledService == null ? null : scheduledService,
    "gps_code": gpsCode == null ? null : gpsCode,
    "iata_code": iataCode == null ? null : iataCode,
    "local_code": localCode == null ? null : localCode,
    "home_link": homeLink == null ? null : homeLink,
    "wikipedia_link": wikipediaLink == null ? null : wikipediaLink,
    "keywords": keywords == null ? null : keywords,
  };
}
