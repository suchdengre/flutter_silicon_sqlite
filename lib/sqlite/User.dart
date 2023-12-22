class User {
  int? id; // optional if you want to include an id
  String name;
  String location;

  User({this.id, required this.name, required this.location});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      location: map['location'],
    );
  }

}
