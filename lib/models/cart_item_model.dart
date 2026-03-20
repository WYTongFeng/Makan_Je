// Path: lib/models/cart_item_model.dart

import 'menu_item_model.dart';

class CartItemModel {
  final MenuItemModel menuItem;
  int quantity;
  List<String>
  specialRemarks; // For customization like "Less sugar", "No spicy"

  CartItemModel({
    required this.menuItem,
    this.quantity = 1,
    this.specialRemarks = const [], // Default is an empty list
  });

  // Calculate total price for this specific cart item
  double get totalPrice => menuItem.price * quantity;
}
