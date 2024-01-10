class Place {
  final int id;
  final String name;
  final double lat;
  final double long;
  final String? media;
  final int? postCount;
  final int? userCount;

  Place({required this.id, required this.name, required this.lat, required this.long, this.media, this.postCount, this.userCount});

  static Place fromDoc(dynamic json, {int? uCount, int? pCount}) {
    return Place(
        id: json['place_id'],
        name: json['name'],
        lat: json['latitude'],
        long: json['longitude'],
        media: json['media'],
        userCount: uCount,
        postCount: pCount
    );
  }

  static Place parse (dynamic json) => fromDoc(json['place'], uCount: json['userCount'], pCount: json['placeCount']);
}