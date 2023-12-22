class Info{
  late int id;
  late String name;
  late String location;

  Info({ required this.name, required this.location});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
    };
  }

  factory Info.fromMap(Map<String, dynamic> map) {
    return Info(
      name: map['name'],
      location: map['location'],
    );
  }
}