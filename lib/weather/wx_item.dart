abstract class WxItem {}

class AirportHeading implements WxItem {
  final String name;

  AirportHeading(this.name);
}

class AirportBody implements WxItem {
  final List<String> metars;
  final List <String> tafors;

  AirportBody(this.metars, this.tafors);
}