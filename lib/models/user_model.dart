import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String role; // 'manager', 'kitchen_staff', 'service_staff'
  final String branchId;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.role,
    required this.branchId,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'] ?? '',
      role: data['role'] ?? 'service_staff',
      branchId: data['branch_id'] ?? '',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'role': role,
      'branch_id': branchId,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
