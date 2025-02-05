class FaceModel {
  int? id;
  String name;
  String imagePath;

  FaceModel({this.id, required this.name, required this.imagePath});

  // Convert a FaceModel object into a Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'imagePath': imagePath};
  }

  // Convert a Map into a FaceModel object
  factory FaceModel.fromMap(Map<String, dynamic> map) {
    return FaceModel(
      id: map['id'],
      name: map['name'],
      imagePath: map['imagePath'],
    );
  }
}
