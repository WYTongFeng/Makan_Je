// Path: lib/views/staff/kds_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/order_model.dart';
import '../../data/services/database_service.dart';

class KdsView extends StatefulWidget {
  const KdsView({Key? key}) : super(key: key);

  @override
  State<KdsView> createState() => _KdsViewState();
}

class _KdsViewState extends State<KdsView> {
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    // Force the screen to Landscape Mode for KDS
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Revert back to allowed orientations when leaving KDS
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _markOrderAsReady(String orderId) async {
    try {
      // Update the status in Firebase
      await _dbService.updateOrderStatus(orderId, 'ready');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order $orderId marked as READY!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark order as ready: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFF9943B),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardColor: const Color(0xFF2C2C2C),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Kitchen Display System (KDS)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
          ),
          centerTitle: true,
        ),
        // Implement StreamBuilder to listen to real-time orders
        body: StreamBuilder<List<OrderModel>>(
          stream: _dbService.getPendingOrdersStream(),
          builder: (context, snapshot) {
            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFF9943B)),
              );
            }

            // 2. Error State (This will catch the permission denied error for now)
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Database Error:\n${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // 3. Success State
            final orders = snapshot.data ?? [];

            // If no pending orders
            if (orders.isEmpty) {
              return const Center(
                child: Text(
                  'No pending orders. Kitchen is clear!',
                  style: TextStyle(color: Colors.grey, fontSize: 24.0),
                ),
              );
            }

            // Render the list of tickets
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderTicket(orders[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderTicket(OrderModel order) {
    final int waitingMinutes = DateTime.now()
        .difference(order.createdAt)
        .inMinutes;
    final bool isUrgent = waitingMinutes >= 15;

    return Container(
      width: 350.0,
      margin: const EdgeInsets.only(right: 16.0),
      child: Dismissible(
        key: Key(order.orderId),
        direction: DismissDirection.up,
        onDismissed: (direction) {
          _markOrderAsReady(order.orderId);
        },
        background: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12.0),
          ),
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 64.0),
              SizedBox(height: 8.0),
              Text(
                'SWIPED TO READY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: isUrgent ? Colors.red : Colors.transparent,
              width: 2.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Table ${order.tableNumber}',
                      style: const TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$waitingMinutes min',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: isUrgent ? Colors.red : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey, thickness: 1.0),
                const SizedBox(height: 8.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: order.items.length,
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity}x ',
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF9943B),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (item.specialRemarks.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 36.0,
                                  top: 4.0,
                                ),
                                child: Text(
                                  '*** ${item.specialRemarks.join(', ')} ***',
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: () => _markOrderAsReady(order.orderId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'READY (Tap or Swipe Up)',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
