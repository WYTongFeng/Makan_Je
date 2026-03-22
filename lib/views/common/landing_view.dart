import 'package:flutter/material.dart';
import '../customer/scan_qr_view.dart';
import '../customer/menu_view.dart';
import 'login_view.dart';
import '../../data/services/session_service.dart';
import '../../data/services/database_service.dart';
import '../../models/cart_item_model.dart';
import '../../models/menu_item_model.dart';
import '../customer/split_bill_view.dart';
import '../../core/theme/app_theme.dart';

import 'map_location_view.dart';

class LandingView extends StatefulWidget {
  const LandingView({Key? key}) : super(key: key);

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  int? _activeTableNumber;
  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final table = await _sessionService.getActiveTable();
    if (mounted) {
      setState(() {
        _activeTableNumber = table;
      });
    }
  }

  Future<void> _clearSession() async {
    await _sessionService.clearSession();
    setState(() {
      _activeTableNumber = null;
    });
  }

  // Guard mechanism to prevent exiting if orders are unpaid
  Future<void> _guardActiveSession(Function onClearAllowed) async {
    if (_activeTableNumber == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
    );

    try {
      final activeOrders = await DatabaseService().getActiveOrdersForTable(_activeTableNumber!);
      if (mounted) Navigator.pop(context); // close loader

      if (activeOrders.isEmpty) {
        // Safe to leave table
        await _clearSession();
        onClearAllowed();
      } else {
        // Unpaid items exist! Block exit and show Bill
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please pay your active bill before leaving!'), backgroundColor: Colors.red),
          );
        }

        double totalBill = 0.0;
        final List<CartItemModel> combinedItems = [];
        final List<String> orderIds = [];

        for (var order in activeOrders) {
          orderIds.add(order.orderId);
          totalBill += order.totalAmount;
          for (var orderItem in order.items) {
            combinedItems.add(
              CartItemModel(
                menuItem: MenuItemModel(
                  itemId: orderItem.itemId,
                  nameEn: orderItem.name,
                  nameMy: orderItem.name,
                  category: 'Order',
                  price: orderItem.priceAtTimeOfOrder,
                  imageUrl: '',
                  isSoldOut: false,
                  customizationOptions: [],
                  description: '',
                  allergens: [],
                ),
                specialRemarks: orderItem.specialRemarks,
                quantity: orderItem.quantity,
              ),
            );
          }
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SplitBillView(
                cartItems: combinedItems,
                grandTotal: totalBill,
                orderIds: orderIds,
              ),
            ),
          ).then((isPaid) {
            // Once securely paid, allow them to check out
            if (isPaid == true) {
              _clearSession();
              onClearAllowed();
            }
          });
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error validating session: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleYellow, // Cream background
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // App Logo
            Image.asset(
              'assets/images/logo.png',
              height: 180, // Slightly larger for better visual impact
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            const Text(
              'Simply Eat. Scan to Order.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 50),

            if (_activeTableNumber != null) ...[
              // Active Session UI
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.table_restaurant, color: AppTheme.primaryOrange),
                        const SizedBox(width: 8),
                        Text(
                          'Currently at Table $_activeTableNumber',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MenuView(tableNumber: _activeTableNumber!)),
                          ).then((_) => _loadSession());
                        },
                        icon: const Icon(Icons.restaurant_menu, color: Colors.white),
                        label: const Text('Return to Menu & Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _guardActiveSession(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Session ended successfully.')),
                        );
                      }),
                      child: const Text('Checkout / End Session', style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Secondary Scan New QR Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _guardActiveSession(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ScanQrView()),
                        ).then((_) => _loadSession());
                      });
                    },
                    icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryOrange),
                    label: const Text('Scan New Table', style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Default No Session UI (Giant CTA)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScanQrView()),
                      ).then((_) => _loadSession());
                    },
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    label: const Text(
                      'Scan Table QR to Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Find Us Map Button
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapLocationView()),
                );
              },
              icon: const Icon(Icons.location_on, color: AppTheme.primaryOrange),
              label: const Text('Find Us on Google Maps', style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            // Hidden Staff Login Link
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
              child: const Text(
                'Staff Login',
                style: TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
