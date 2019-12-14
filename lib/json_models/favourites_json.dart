// To parse this JSON data, do
//
//     final favourites = favouritesFromJson(jsonString);

import 'dart:convert';

Favourites favouritesFromJson(String str) => Favourites.fromJson(json.decode(str));

String favouritesToJson(Favourites data) => json.encode(data.toJson());

class Favourites {
  String title;
  String airports;

  Favourites({
    this.title,
    this.airports,
  });

  factory Favourites.fromJson(Map<String, dynamic> json) => Favourites(
    title: json["title"] == null ? null : json["title"],
    airports: json["airports"] == null ? null : json["airports"],
  );

  Map<String, dynamic> toJson() => {
    "title": title == null ? null : title,
    "airports": airports == null ? null : airports,
  };
}