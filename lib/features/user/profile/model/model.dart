class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String role;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory ProfileModel.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return ProfileModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
    );
  }
}