class MenuItemModel {
  final String itemId;
  final String nameEn;
  final String nameMy;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  bool isSoldOut; // Not final, because the manager can change this!
  final List<String> allergens;
  final List<String> customizationOptions;

  MenuItemModel({
    required this.itemId,
    required this.nameEn,
    required this.nameMy,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isSoldOut = false,
    required this.allergens,
    required this.customizationOptions,
  });

  // Convert Firestore Map to Dart Object
  factory MenuItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MenuItemModel(
      itemId: id,
      nameEn: data['name_en'] ?? '',
      nameMy: data['name_my'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      imageUrl: data['image_url'] ?? '',
      isSoldOut: data['is_sold_out'] ?? false,
      allergens: List<String>.from(data['allergens'] ?? []),
      customizationOptions: List<String>.from(
        data['customization_options'] ?? [],
      ),
    );
  }

  // Convert Dart Object back to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'name_en': nameEn,
      'name_my': nameMy,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'is_sold_out': isSoldOut,
      'allergens': allergens,
      'customization_options': customizationOptions,
    };
  }
}
