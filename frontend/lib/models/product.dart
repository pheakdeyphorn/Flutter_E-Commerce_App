class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String brand; // បន្ថែមត្រង់នេះ
  final int stockCount;
  final bool isTrending;
  final double oldPrice;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.brand, // បន្ថែមត្រង់នេះ
    required this.stockCount,
    required this.isTrending,
    required this.oldPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] ?? '',
      // Support ទាំងទម្រង់ String (ចាស់) និង Object (ថ្មី)
      category: json['category'] is Map
          ? json['category']['name']
          : (json['category'] ?? 'Other'),
      brand: json['brand'] is Map
          ? json['brand']['name']
          : (json['brand'] ?? 'Unknown'), // បន្ថែមត្រង់នេះ
      stockCount: json['stock_count'] ?? 0,
      isTrending: json['is_trending'] ?? false,
      oldPrice: (json['old_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
