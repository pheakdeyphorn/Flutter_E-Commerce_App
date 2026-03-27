class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stockCount;
  final bool isTrending; // New
  final double oldPrice;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stockCount,
    required this.isTrending, // New
    required this.oldPrice,
  });

  // This "Factory" constructor converts your MongoDB JSON into a Flutter Object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'], // MongoDB uses _id
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num)
          .toDouble(), // Ensures it handles integers or doubles
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? 'Other',
      stockCount: json['stock_count'] ?? 0,
      isTrending: json['is_trending'] ?? false,
      oldPrice: (json['old_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
