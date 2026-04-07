import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;

  const ProductGridItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- ផ្នែករូបភាព និង Category Badge ---
          Stack(
            children: [
              Container(
                height: 140, // កំណត់កម្ពស់ឱ្យថេរដើម្បីឱ្យ Card ស្មើគ្នា
                width: double.infinity,
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, color: colorScheme.outline),
                ),
              ),
              // បង្ហាញ Category នៅជ្រុងខាងស្តាំលើ
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- ផ្នែកព័ត៌មានលម្អិត ---
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // បង្ហាញ Brand (ឧទាហរណ៍៖ MSI, Corsair)
                Text(
                  product.brand.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),

                // --- ផ្នែកតម្លៃ ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\$${product.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (product.oldPrice > 0)
                          Text(
                            "\$${product.oldPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: colorScheme.outline,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    // ប៊ូតុង Add to Cart តូច
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
