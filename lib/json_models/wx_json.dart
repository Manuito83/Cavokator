// To parse this JSON data, do
//
//     final wxJson = wxJsonFromJson(jsonString);

import 'dart:convert';

List<WxJson> wxJsonFromJson(String str) {
  final jsonData = json.decode(str);
  return List<WxJson>.from(jsonData.map((x) => WxJson.fromJson(x)));
}

String wxJsonToJson(List<WxJson> data) {
  final dyn = List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}

class WxJson {
  String? airportIdIcao;
  String? airportIdIata;
  List<Metar>? metars;
  List<Tafor>? tafors;
  FullAirportDetails? fullAirportDetails;
  bool? airportNotFound;

  WxJson({
    this.airportIdIcao,
    this.airportIdIata,
    this.metars,
    this.tafors,
    this.fullAirportDetails,
    this.airportNotFound,
  });

  factory WxJson.fromJson(Map<String, dynamic> json) => WxJson(
        airportIdIcao: json["AirportIdIcao"] == null ? null : json["AirportIdIcao"],
        airportIdIata: json["AirportIdIata"] == null ? null : json["AirportIdIata"],
        metars: json["Metars"] == null ? null : List<Metar>.from(json["Metars"].map((x) => Metar.fromJson(x))),
        tafors: json["Tafors"] == null ? null : List<Tafor>.from(json["Tafors"].map((x) => Tafor.fromJson(x))),
        fullAirportDetails:
            json["FullAirportDetails"] == null ? null : FullAirportDetails.fromJson(json["FullAirportDetails"]),
        airportNotFound: json["AirportNotFound"] == null ? null : json["AirportNotFound"],
      );

  Map<String, dynamic> toJson() => {
        "AirportIdIcao": airportIdIcao == null ? null : airportIdIcao,
        "AirportIdIata": airportIdIata == null ? null : airportIdIata,
        "Metars": metars == null ? null : List<dynamic>.from(metars!.map((x) => x.toJson())),
        "Tafors": tafors == null ? null : List<dynamic>.from(tafors!.map((x) => x.toJson())),
        "FullAirportDetails": fullAirportDetails == null ? null : fullAirportDetails!.toJson(),
        "AirportNotFound": airportNotFound == null ? null : airportNotFound,
      };
}

class FullAirportDetails {
  String? id;
  String? ident;
  String? type;
  String? name;
  String? latitudeDeg;
  String? longitudeDeg;
  String? elevationFt;
  String? continent;
  String? isoCountry;
  String? isoRegion;
  String? municipality;
  String? scheduledService;
  String? gpsCode;
  String? iataCode;
  String? localCode;
  String? homeLink;
  String? wikipediaLink;
  String? keywords;

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

  factory FullAirportDetails.fromJson(Map<String, dynamic> json) => FullAirportDetails(
        id: json["id"] == null ? null : json["id"],
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

class Metar {
  String? metar;
  String? metarTime;

  Metar({
    this.metar,
    this.metarTime,
  });

  factory Metar.fromJson(Map<String, dynamic> json) => Metar(
        metar: json["Metar"] == null ? null : json["Metar"],
        metarTime: json["MetarTime"] == null ? null : json["MetarTime"],
      );

  Map<String, dynamic> toJson() => {
        "Metar": metar == null ? null : metar,
        "MetarTime": metarTime == null ? null : metarTime,
      };
}

class Tafor {
  String? tafor;
  String? taforTime;

  Tafor({
    this.tafor,
    this.taforTime,
  });

  factory Tafor.fromJson(Map<String, dynamic> json) => Tafor(
        tafor: json["Tafor"] == null ? null : json["Tafor"],
        taforTime: json["TaforTime"] == null ? null : json["TaforTime"],
      );

  Map<String, dynamic> toJson() => {
        "Tafor": tafor == null ? null : tafor,
        "TaforTime": taforTime == null ? null : taforTime,
      };
}
