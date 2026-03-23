import 'package:flutter/material.dart';
import '../../../data/services/database_service.dart';
import '../../../models/menu_item_model.dart';
import '../../../view_models/manager_view_model.dart';
import '../../../core/theme/app_theme.dart';
import 'menu_item_form_view.dart'; // Import Form

class MenuMgmtView extends StatelessWidget {
  MenuMgmtView({Key? key}) : super(key: key);

  final DatabaseService _dbService = DatabaseService();
  final ManagerViewModel _viewModel = ManagerViewModel();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleYellow, // Makan Je Cream background
      appBar: AppBar(
        title: const Text(
          'Menu Availability',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.darkRed,
        elevation: 0,
        actions: [],
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withOpacity(0.2),
            height: 1.0,
          ),
        ),
      ),
      body: StreamBuilder<List<MenuItemModel>>(
        stream: _dbService.getMenuItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppTheme.darkRed),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryOrange),
            );
          }

          final menuItems = snapshot.data ?? [];

          if (menuItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No menu items found.\nTap + to add one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            itemCount: menuItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = menuItems[index];

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: item.isSoldOut ? Colors.grey.shade100 : AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  border: item.isSoldOut ? Border.all(color: Colors.grey.shade300) : null,
                  boxShadow: item.isSoldOut 
                    ? [] 
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.lightOrange,
                          borderRadius: BorderRadius.circular(12),
                          image: item.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: item.imageUrl.startsWith('http')
                                      ? NetworkImage(item.imageUrl) as ImageProvider
                                      : AssetImage(item.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: item.imageUrl.isEmpty
                            ? const Icon(Icons.fastfood, color: AppTheme.primaryOrange, size: 32)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      // Item Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nameEn,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: item.isSoldOut ? Colors.grey : AppTheme.darkGrey,
                                decoration: item.isSoldOut ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'RM ${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Actions
                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MenuItemFormView(existingItem: item),
                                    ),
                                  );
                                },
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppTheme.darkRed),
                                onPressed: () => _showDeleteConfirmation(context, item),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              Text(
                                item.isSoldOut ? 'SOLD OUT' : 'AVAILABLE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: item.isSoldOut ? Colors.red : Colors.green,
                                ),
                              ),
                              const SizedBox(height: 2),
                              SizedBox(
                                height: 35,
                                child: Switch(
                                  value: !item.isSoldOut,
                                  activeColor: Colors.white,
                                  activeTrackColor: Colors.green,
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.red.shade300,
                                  onChanged: (bool value) async {
                                    await _viewModel.toggleItemAvailability(
                                      item.itemId,
                                      item.isSoldOut,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MenuItemFormView()),
          );
        },
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add, color: AppTheme.white),
        label: const Text('Add Menu Item', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MenuItemModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${item.nameEn}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _viewModel.deleteItem(item.itemId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item deleted successfully'))
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'))
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: AppTheme.darkRed)),
            ),
          ],
        );
      },
    );
  }
}
