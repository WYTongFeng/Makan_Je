import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/menu_item_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. GET MENU ITEMS (REAL-TIME STREAM)
  // This listens for changes so if a manager clicks "Sold Out", it updates instantly
  Stream<List<MenuItemModel>> getMenuItemsStream() {
    return _db.collection('menu_items').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MenuItemModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // 2. UPDATE OUT-OF-STOCK STATUS (FOR MANAGER)
  Future<void> updateSoldOutStatus(String itemId, bool isSoldOut) async {
    try {
      await _db.collection('menu_items').doc(itemId).update({
        'is_sold_out': isSoldOut,
      });
    } catch (e) {
      print("Error updating status: $e");
      rethrow; // Pass error to ViewModel to show a snackbar
    }
  }
}
