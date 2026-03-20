// Path: lib/views/customer/split_bill_view.dart

import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';

class SplitBillView extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final double grandTotal;

  const SplitBillView({
    Key? key,
    required this.cartItems,
    required this.grandTotal,
  }) : super(key: key);

  @override
  State<SplitBillView> createState() => _SplitBillViewState();
}

class _SplitBillViewState extends State<SplitBillView> {
  // State for 'Split Equally' tab
  int _splitCount = 2;

  // State for 'Pay by Item' tab
  late List<bool> _selectedItems;

  @override
  void initState() {
    super.initState();
    // Initialize all items as unselected for the 'Pay by Item' feature
    _selectedItems = List.generate(widget.cartItems.length, (index) => false);
  }

  // Calculate the total for specifically selected items
  double _calculateSelectedItemsTotal() {
    double total = 0.0;
    for (int i = 0; i < widget.cartItems.length; i++) {
      if (_selectedItems[i]) {
        total += widget.cartItems[i].totalPrice;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // Using DefaultTabController to manage the two split methods
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Split Bill'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Split Equally'),
              Tab(text: 'Pay by Item'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildSplitEquallyTab(), _buildPayByItemTab()],
        ),
      ),
    );
  }

  // --- Tab 1: Split Equally ---
  Widget _buildSplitEquallyTab() {
    final double amountPerPerson = widget.grandTotal / _splitCount;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Grand Total',
            style: TextStyle(fontSize: 18.0, color: Colors.grey),
          ),
          const SizedBox(height: 8.0),
          Text(
            'RM ${widget.grandTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48.0),
          const Text('How many people?', style: TextStyle(fontSize: 18.0)),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _splitCount > 2
                    ? () {
                        setState(() {
                          _splitCount--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 36.0,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 24.0),
              Text(
                '$_splitCount',
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24.0),
              IconButton(
                onPressed: _splitCount < 10
                    ? () {
                        setState(() {
                          _splitCount++;
                        });
                      }
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 36.0,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 48.0),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            child: Column(
              children: [
                const Text(
                  'Each Person Pays',
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'RM ${amountPerPerson.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildGenerateQRButton(amountPerPerson),
        ],
      ),
    );
  }

  // --- Tab 2: Pay by Item ---
  Widget _buildPayByItemTab() {
    final double myTotal = _calculateSelectedItemsTotal();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Select the items you consumed',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = widget.cartItems[index];
              return CheckboxListTile(
                title: Text(cartItem.menuItem.nameEn),
                subtitle: Text('Qty: ${cartItem.quantity}'),
                secondary: Text(
                  'RM ${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                value: _selectedItems[index],
                activeColor: Theme.of(context).primaryColor,
                onChanged: (bool? value) {
                  setState(() {
                    _selectedItems[index] = value ?? false;
                  });
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Total',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'RM ${myTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildGenerateQRButton(myTotal),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Reusable button for both tabs to proceed to payment/QR generation
  Widget _buildGenerateQRButton(double amountToPay) {
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: ElevatedButton(
        onPressed: amountToPay > 0
            ? () {
                // TODO: Generate QR Code for counter scanning
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Generating QR for RM ${amountToPay.toStringAsFixed(2)}...',
                    ),
                  ),
                );
              }
            : null,
        child: const Text('Generate Pay QR'),
      ),
    );
  }
}
