// Path: lib/views/customer/split_bill_view.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/cart_item_model.dart';
import '../../data/services/database_service.dart';

class SplitBillView extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final double grandTotal;
  final List<String> orderIds;

  const SplitBillView({
    Key? key,
    required this.cartItems,
    required this.grandTotal,
    required this.orderIds,
  }) : super(key: key);

  @override
  State<SplitBillView> createState() => _SplitBillViewState();
}

class _SplitBillViewState extends State<SplitBillView> {
  int _splitCount = 2;
  late List<bool> _selectedItems;

  @override
  void initState() {
    super.initState();
    // Initialize the selection list based on current items
    _selectedItems = List.generate(widget.cartItems.length, (index) => false);
  }

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
                    ? () => setState(() => _splitCount--)
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
                    ? () => setState(() => _splitCount++)
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
          _buildGenerateQRButton(amountPerPerson, isSplitEqually: true),
        ],
      ),
    );
  }

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

              // Note: We use isSoldOut as a proxy for "isPaid" here to simplify UI logic
              // In a real Distinction project, you'd add isPaid to MenuItemModel
              final bool isAlreadyPaid = cartItem.menuItem.isSoldOut;

              return CheckboxListTile(
                title: Text(
                  cartItem.menuItem.nameEn,
                  style: TextStyle(
                    decoration: isAlreadyPaid
                        ? TextDecoration.lineThrough
                        : null,
                    color: isAlreadyPaid ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Text('Qty: ${cartItem.quantity}'),
                secondary: Text(
                  'RM ${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAlreadyPaid ? Colors.grey : Colors.black,
                  ),
                ),
                value: _selectedItems[index],
                activeColor: Theme.of(context).primaryColor,
                // Disable checkbox if item is already paid
                onChanged: isAlreadyPaid
                    ? null
                    : (bool? value) {
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
                _buildGenerateQRButton(myTotal, isSplitEqually: false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateQRButton(
    double amountToPay, {
    required bool isSplitEqually,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: ElevatedButton(
        onPressed: amountToPay > 0
            ? () => _showQRDialog(amountToPay, isSplitEqually)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: const Text('Generate Pay QR'),
      ),
    );
  }

  void _showQRDialog(double amount, bool isSplitEqually) {
    final String qrData = 'MakanJe_Pay_RM_${amount.toStringAsFixed(2)}';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Scan at Counter',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Show this QR code to the cashier to pay your portion.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: 200.0,
                height: 200.0,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'RM ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final dbService = DatabaseService();

                if (isSplitEqually) {
                  // Equal payment: equivalent to directly closing all related orders.
                  for (String orderId in widget.orderIds) {
                    await dbService.updateOrderStatus(orderId, 'paid');
                  }
                } else {
                  // Single Item Payment Logic (Distinction Logic)
                  for (int i = 0; i < widget.cartItems.length; i++) {
                    if (_selectedItems[i]) {
                      // Parse "OrderId|ItemIndex"
                      String rawData = widget.cartItems[i].menuItem.description;
                      List<String> parts = rawData.split('|');
                      String orderId = parts[0];
                      int itemIndex = int.parse(parts[1]);

                      // Call the local payment method instead of the global paid method.
                      await dbService.markOrderItemAsPaid(orderId, itemIndex);
                    }
                  }
                }
                // --- DISTINCTION LOGIC END ---

                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment Successful! Thank you.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Simulate Payment',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
