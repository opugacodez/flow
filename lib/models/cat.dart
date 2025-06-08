class Cat {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String color;
  final String size;
  final String location;
  final String description;
  final String profileImageUrl;
  final List<String> images;
  final String healthHistory;
  final String personality;
  final bool vaccinated;
  final bool neutered;
  bool isFavorited;
  final String status;

  Cat({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.color,
    required this.size,
    required this.location,
    required this.description,
    required this.profileImageUrl,
    required this.images,
    required this.healthHistory,
    required this.personality,
    this.vaccinated = false,
    this.neutered = false,
    this.isFavorited = false,
    this.status = 'Disponível',
  });

  factory Cat.fromMap(String id, Map<String, dynamic> data) {
    return Cat(
      id: id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      color: data['color'] ?? '',
      size: data['size'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      healthHistory: data['healthHistory'] ?? '',
      personality: data['personality'] ?? '',
      vaccinated: data['vaccinated'] ?? false,
      neutered: data['neutered'] ?? false,
      status: data['status'] ?? 'Disponível',
    );
  }
}