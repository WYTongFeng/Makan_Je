import 'package:flutter/material.dart';
import '../../../data/services/database_service.dart';
import '../../../models/menu_item_model.dart';
import '../../../view_models/manager_view_model.dart';

class MenuMgmtView extends StatelessWidget {
  MenuMgmtView({Key? key}) : super(key: key);

  // Initialize the database service and view model
  final DatabaseService _dbService = DatabaseService();
  final ManagerViewModel _viewModel = ManagerViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu Availability Toggle',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(
          0xFFF9943B,
        ), // Your Primary Orange from the proposal
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // StreamBuilder listens to Firebase in real-time
      body: StreamBuilder<List<MenuItemModel>>(
        stream: _dbService.getMenuItemsStream(),
        builder: (context, snapshot) {
          // 1. Handle Errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 2. Handle Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF9943B)),
            );
          }

          final menuItems = snapshot.data ?? [];

          // 3. Handle Empty State
          if (menuItems.isEmpty) {
            return const Center(
              child: Text('No menu items found. Add a document in Firestore!'),
            );
          }

          // 4. Build the List of Toggle Switches
          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(
                    Icons.fastfood,
                    color: Colors.grey,
                  ), // Placeholder for image
                  title: Text(
                    item.nameEn,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: item.isSoldOut
                          ? TextDecoration.lineThrough
                          : null, // Cross out if sold out
                    ),
                  ),
                  subtitle: Text('RM ${item.price.toStringAsFixed(2)}'),
                  trailing: Switch(
                    // Switch is ON if the item is NOT sold out
                    value: !item.isSoldOut,
                    activeColor: const Color(0xFFF9943B),
                    onChanged: (bool value) async {
                      // Trigger the ViewModel function you wrote earlier
                      await _viewModel.toggleItemAvailability(
                        item.itemId,
                        item.isSoldOut,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
