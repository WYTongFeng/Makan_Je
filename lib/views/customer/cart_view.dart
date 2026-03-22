// Path: lib/views/customer/cart_view.dart

import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';
import 'split_bill_view.dart';
import '../../models/order_model.dart';
import '../../data/services/database_service.dart';

class CartView extends StatefulWidget {
  // Passing mock cart items for UI testing
  final List<CartItemModel> cartItems;

  const CartView({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  double _calculateGrandTotal() {
    double total = 0;
    for (var item in widget.cartItems) {
      total += item.totalPrice;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Order')),
      body: widget.cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty. Add some delicious food!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = widget.cartItems[index];
                      return _buildCartItemTile(cartItem);
                    },
                  ),
                ),
                _buildCheckoutBar(context),
              ],
            ),
    );
  }

  Widget _buildCartItemTile(CartItemModel cartItem) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                cartItem.menuItem.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12.0),
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.menuItem.nameEn,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  if (cartItem.specialRemarks.isNotEmpty)
                    Text(
                      'Remarks: ${cartItem.specialRemarks.join(', ')}', // Updated logic
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.redAccent,
                      ),
                    ),
                  const SizedBox(height: 4.0),
                  Text(
                    'RM ${cartItem.menuItem.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity Indicator
            Text(
              'x${cartItem.quantity}',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context) {
    final grandTotal = _calculateGrandTotal();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  'RM ${grandTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.cartItems.isEmpty
                    ? null
                    : () async {
                        try {
                          // 1. Convert CartItems to OrderItems
                          final List<OrderItem> orderItems = widget.cartItems
                              .map((cartItem) {
                                return OrderItem(
                                  itemId: cartItem.menuItem.itemId,
                                  name: cartItem.menuItem.nameEn,
                                  quantity: cartItem.quantity,
                                  priceAtTimeOfOrder: cartItem.menuItem.price,
                                  specialRemarks: cartItem.specialRemarks,
                                );
                              })
                              .toList();

                          // 2. Construct the OrderModel
                          final newOrder = OrderModel(
                            orderId: '', // Firebase will generate the actual ID
                            tableNumber: 1, // Mock table number
                            status: 'pending',
                            createdAt: DateTime.now(),
                            totalAmount: _calculateGrandTotal(),
                            splitType: 'none',
                            items: orderItems,
                          );

                          // 3. Send to Firebase and get the generated ID
                          final dbService = DatabaseService();
                          final String generatedOrderId = await dbService
                              .placeOrder(newOrder);

                          // 4. Show success message and navigate back to Menu
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Order sent to kitchen successfully!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Return the specific order ID to the MenuView
                            Navigator.pop(context, generatedOrderId);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to place order: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          print('Firebase Exception: $e');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Place Order',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
