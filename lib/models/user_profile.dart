class AppUser {
  final String uid;
  final String? email;
  final String? name;

  const AppUser({
    required this.uid,
    this.email,
    this.name,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'],
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
    };
  }
}
