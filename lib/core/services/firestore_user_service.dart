import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore user document model.
class FirestoreUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  FirestoreUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';

  factory FirestoreUser.fromMap(String uid, Map<String, dynamic> map) {
    return FirestoreUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'employee',
      isActive: map['is_active'] as bool? ?? true,
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}

/// Firestore service for managing users/{uid} collection.
/// Handles role and access control data.
class FirestoreUserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';

  /// Get user document by UID.
  /// Returns null if document doesn't exist.
  static Future<FirestoreUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return FirestoreUser.fromMap(uid, doc.data()!);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  /// Create user document with the given UID.
  static Future<bool> createUser({
    required String uid,
    required String name,
    required String email,
    required String role,
    bool isActive = true,
  }) async {
    try {
      await _firestore.collection(_collection).doc(uid).set({
        'name': name,
        'email': email.toLowerCase().trim(),
        'role': role,
        'is_active': isActive,
        'created_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error creating user: $e');
      return false;
    }
  }

  /// Update user active status.
  static Future<bool> updateActiveStatus(String uid, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'is_active': isActive,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating user status: $e');
      return false;
    }
  }

  /// Get all employees (role == 'employee').
  /// Note: If Firestore throws index error, we fetch without orderBy and sort client-side.
  static Future<List<FirestoreUser>> getAllEmployees() async {
    try {
      // Try with orderBy first (requires composite index)
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await _firestore
            .collection(_collection)
            .where('role', isEqualTo: 'employee')
            .orderBy('created_at', descending: true)
            .get();
      } catch (e) {
        // If index error, fetch without orderBy and sort client-side
        debugPrint('Firestore index error, fetching without orderBy: $e');
        snapshot = await _firestore
            .collection(_collection)
            .where('role', isEqualTo: 'employee')
            .get();
      }
      
      debugPrint('Fetched ${snapshot.docs.length} employees from Firestore');
      
      final employees = snapshot.docs
          .map((doc) {
            debugPrint('Employee doc: ${doc.id} => ${doc.data()}');
            return FirestoreUser.fromMap(doc.id, doc.data());
          })
          .toList();
      
      // Sort by created_at descending (in case we had to skip orderBy)
      employees.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return employees;
    } catch (e) {
      debugPrint('Error getting employees: $e');
      return [];
    }
  }

  /// Check if user exists.
  static Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Delete a user by UID.
  static Future<bool> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }
}
