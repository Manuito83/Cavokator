// To parse this JSON data, do
//
//     final favourite = favouriteFromJson(jsonString);

import 'dart:convert';

List<Favourite> favouriteListFromJson(String str) => List<Favourite>.from(json.decode(str).map((x) => Favourite.fromJson(x)));
String favouriteListToJson(List<Favourite> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Favourite {
  String title;
  List<String> airports;

  Favourite({
    this.title,
    this.airports,
  });

  factory Favourite.fromJson(Map<String, dynamic> json) => Favourite(
    title: json["title"] == null ? null : json["title"],
    airports: json["airports"] == null ? null : List<String>.from(json["airports"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "title": title == null ? null : title,
    "airports": airports == null ? null : List<dynamic>.from(airports.map((x) => x)),
  };

}
