import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/menu_item_model.dart';
import '../../models/order_model.dart'; // Import the OrderModel

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. GET MENU ITEMS (REAL-TIME STREAM)
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
      print("Error updating status: \$e");
      rethrow;
    }
  }

  // 3. CREATE NEW ORDER (FOR CUSTOMER)
  Future<void> placeOrder(OrderModel order) async {
    try {
      // Create a new document reference to let Firebase auto-generate a unique ID
      final docRef = _db.collection('orders').doc();

      // Convert the Dart object to a Map that Firestore understands
      final orderData = order.toFirestore();

      // Save it to the database
      await docRef.set(orderData);
    } catch (e) {
      print("Error placing order: \$e");
      rethrow;
    }
  }
}
