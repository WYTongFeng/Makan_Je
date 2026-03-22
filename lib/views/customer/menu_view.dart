// Path: lib/views/customer/menu_view.dart

import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../../models/cart_item_model.dart';
import 'cart_view.dart';
import 'split_bill_view.dart';
import '../../data/services/database_service.dart';

class MenuView extends StatefulWidget {
  const MenuView({Key? key}) : super(key: key);

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  // Initialize DatabaseService to fetch real-time data
  final DatabaseService _dbService = DatabaseService();

  // Temporary local state to hold cart items before State Management is implemented
  final List<CartItemModel> _currentCart = [];

  // State to hold placed orders that haven't been paid yet
  final List<CartItemModel> _unpaidBill = [];

  // State to hold the IDs of the unpaid orders in Firebase
  final List<String> _unpaidOrderIds = [];

  // Add item to cart with quantity
  void _addToCart(
    MenuItemModel item,
    List<String> selectedRemarks,
    int quantity,
  ) {
    setState(() {
      final existingItemIndex = _currentCart.indexWhere((cartItem) {
        if (cartItem.menuItem.itemId != item.itemId) return false;
        if (cartItem.specialRemarks.length != selectedRemarks.length) {
          return false;
        }
        for (var i = 0; i < selectedRemarks.length; i++) {
          if (cartItem.specialRemarks[i] != selectedRemarks[i]) return false;
        }
        return true;
      });

      if (existingItemIndex >= 0) {
        _currentCart[existingItemIndex].quantity += quantity;
      } else {
        _currentCart.add(
          CartItemModel(
            menuItem: item,
            specialRemarks: List.from(selectedRemarks),
            quantity: quantity,
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.nameEn} (x$quantity) added to order!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show bottom sheet for customization and quantity
  void _showCustomizationSheet(MenuItemModel item) {
    List<String> tempSelectedRemarks = [];
    int tempQuantity = 1;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customize ${item.nameEn}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  if (item.customizationOptions.isNotEmpty) ...[
                    const Text('Select your preferences:'),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      children: item.customizationOptions.map((option) {
                        final isSelected = tempSelectedRemarks.contains(option);
                        return FilterChip(
                          label: Text(option),
                          selected: isSelected,
                          selectedColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          checkmarkColor: Theme.of(context).primaryColor,
                          onSelected: (bool selected) {
                            setSheetState(() {
                              if (selected) {
                                tempSelectedRemarks.add(option);
                              } else {
                                tempSelectedRemarks.remove(option);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: tempQuantity > 1
                                ? () => setSheetState(() => tempQuantity--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Theme.of(context).primaryColor,
                          ),
                          Text(
                            '$tempQuantity',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setSheetState(() => tempQuantity++),
                            icon: const Icon(Icons.add_circle_outline),
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _addToCart(item, tempSelectedRemarks, tempQuantity);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Add to Order - RM ${(item.price * tempQuantity).toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Navigate to Cart and handle returned order ID
  Future<void> _navigateToCart() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartView(cartItems: _currentCart),
      ),
    );

    // If result is a String, it means the order was placed and we got an ID back
    if (result is String) {
      setState(() {
        _unpaidBill.addAll(_currentCart);
        _unpaidOrderIds.add(result); // Save the order ID
        _currentCart.clear();
      });
    } else {
      setState(() {});
    }
  }

  // Navigate directly to the Split Bill view using the unpaid bill items
  void _navigateToSplitBill() {
    if (_unpaidBill.isEmpty) return;

    double totalBill = 0.0;
    for (var item in _unpaidBill) {
      totalBill += item.totalPrice;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SplitBillView(
          cartItems: _unpaidBill,
          grandTotal: totalBill,
          orderIds: _unpaidOrderIds,
        ),
      ),
    ).then((isPaid) {
      // If payment was successful, clear the local bill UI
      if (isPaid == true) {
        setState(() {
          _unpaidBill.clear();
          _unpaidOrderIds.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Makan Je Menu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Receipt / Unpaid Bill Icon
          if (_unpaidBill.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.receipt_long, color: Colors.green),
              onPressed: _navigateToSplitBill,
              tooltip: 'View Bill & Pay',
            ),

          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _navigateToCart,
              ),
              if (_currentCart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_currentCart.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      // StreamBuilder to fetch real-time menu data
      body: StreamBuilder<List<MenuItemModel>>(
        stream: _dbService.getMenuItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error loading menu: \n${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final menuItems = snapshot.data ?? [];

          if (menuItems.isEmpty) {
            return const Center(
              child: Text(
                'Menu is currently empty.',
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuCard(context, item);
              },
            ),
          );
        },
      ),
    );
  }

  // Build individual menu card
  Widget _buildMenuCard(BuildContext context, MenuItemModel item) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                );
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nameEn,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'RM ${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: item.isSoldOut
                          ? null
                          : () => _showCustomizationSheet(item),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(item.isSoldOut ? 'Sold Out' : 'Add'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
