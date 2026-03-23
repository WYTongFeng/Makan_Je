import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/services/database_service.dart';
import '../models/menu_item_model.dart';

class ManagerViewModel extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  Future<void> toggleItemAvailability(String itemId, bool currentStatus) async {
    await _dbService.updateSoldOutStatus(itemId, !currentStatus);
    notifyListeners();
  }

  Future<void> addNewItem(MenuItemModel newItem) async {
    await _dbService.addMenuItem(newItem);
    notifyListeners();
  }

  Future<void> updateItem(MenuItemModel item) async {
    await _dbService.updateMenuItem(item);
    notifyListeners();
  }

  Future<void> deleteItem(String itemId) async {
    await _dbService.deleteMenuItem(itemId);
    notifyListeners();
  }

  Future<void> registerStaffUser(String email, String password, String role) async {
    try {
      // 1. Initialize a secondary Firebase app to avoid logging out the current manager
      FirebaseApp tempApp = await Firebase.initializeApp(
        name: 'tempRegisterApp',
        options: Firebase.app().options,
      );

      // 2. Create the user in the secondary app instance
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: tempApp).createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 3. Save the role in the main Firestore instance
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': email.trim(),
          'role': role.toLowerCase(),
        });
      }

      // 4. Clean up: Delete the secondary app so it doesn't leak memory or credentials
      await tempApp.delete();
      
    } catch (e) {
      debugPrint('Registration Error: \$e');
      rethrow;
    }
  }
}
