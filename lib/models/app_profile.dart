class AppProfile {
  final String id;
  final String name;

  const AppProfile({required this.id, required this.name});

  factory AppProfile.fromJson(Map<String, dynamic> json) {
    return AppProfile(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

