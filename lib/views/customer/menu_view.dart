import 'package:flutter/material.dart';

class MenuView extends StatelessWidget {
  const MenuView({Key? key}) : super(key: key);

  // Mock data for UI layout testing.
  // To be replaced by ViewModel/Firebase data later.
  final List<Map<String, dynamic>> mockMenuItems = const [
    {
      "name": "Nasi Lemak Ayam",
      "price": 15.90,
      "imageUrl": "https://via.placeholder.com/300",
    },
    {
      "name": "Mee Goreng Mamak",
      "price": 10.50,
      "imageUrl": "https://via.placeholder.com/300",
    },
    {
      "name": "Teh Tarik Ais",
      "price": 4.50,
      "imageUrl": "https://via.placeholder.com/300",
    },
    {
      "name": "Roti Canai",
      "price": 2.50,
      "imageUrl": "https://via.placeholder.com/300",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Makan Je Menu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Shopping cart icon for checkout / split bill navigation
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // TODO: Navigate to Cart/Payment View
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            childAspectRatio: 0.75, // Adjust to allocate 60% space for images
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: mockMenuItems.length,
          itemBuilder: (context, index) {
            final item = mockMenuItems[index];
            return _buildMenuCard(context, item);
          },
        ),
      ),
    );
  }

  // Extracted widget method to keep the build function clean
  Widget _buildMenuCard(BuildContext context, Map<String, dynamic> item) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Food Image (Allocated roughly 60% of card space)
          Expanded(
            flex: 6,
            child: Image.network(
              item['imageUrl'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon if image fails to load
                return const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                );
              },
            ),
          ),
          // 2. Item Details & Button (Allocated roughly 40% of card space)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'RM ${item['price'].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Add to cart logic
                      },
                      // Styling is inherited from AppTheme, but we ensure it relies on primary color
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Add'),
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
