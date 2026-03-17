import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String itemId;
  final String name;
  final int quantity;
  final double priceAtTimeOfOrder;
  final List<String> specialRemarks;

  OrderItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.priceAtTimeOfOrder,
    required this.specialRemarks,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      itemId: data['item_id'] ?? '',
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 1,
      priceAtTimeOfOrder: (data['price_at_time_of_order'] ?? 0.0).toDouble(),
      specialRemarks: List<String>.from(data['special_remarks'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'name': name,
      'quantity': quantity,
      'price_at_time_of_order': priceAtTimeOfOrder,
      'special_remarks': specialRemarks,
    };
  }
}

class OrderModel {
  final String orderId;
  final int tableNumber;
  String status; // 'pending', 'cooking', 'ready', 'paid'
  final DateTime createdAt;
  final double totalAmount;
  final String splitType;
  final List<OrderItem> items;

  OrderModel({
    required this.orderId,
    required this.tableNumber,
    required this.status,
    required this.createdAt,
    required this.totalAmount,
    required this.splitType,
    required this.items,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    var itemsList = data['items'] as List? ?? [];
    List<OrderItem> parsedItems = itemsList
        .map((i) => OrderItem.fromMap(i))
        .toList();

    return OrderModel(
      orderId: id,
      tableNumber: data['table_number'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      totalAmount: (data['total_amount'] ?? 0.0).toDouble(),
      splitType: data['split_type'] ?? 'none',
      items: parsedItems,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'table_number': tableNumber,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'total_amount': totalAmount,
      'split_type': splitType,
      'items': items.map((i) => i.toMap()).toList(),
    };
  }
}
