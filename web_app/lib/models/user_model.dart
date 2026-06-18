import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin('ADMIN'),
  security('SECURITY'),
  sdTeams('SD_TEAMS');

  const UserRole(this.rawValue);
  final String rawValue;
}

class UserProfile {
  final String id;
  final String email;
  final String role;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.parse(data['createdAt'].toString()))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
