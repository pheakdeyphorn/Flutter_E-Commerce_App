import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;

  const ProductGridItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Access the current theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      // Card color will now automatically adapt to Dark/Light mode from AppTheme
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PRODUCT IMAGE ---
          Expanded(
            child: Container(
              width: double.infinity,
              color: colorScheme.surfaceContainerHighest.withOpacity(
                0.3,
              ), // Light grey placeholder area
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  color: colorScheme.outline,
                  size: 40,
                ),
              ),
            ),
          ),

          // --- PRODUCT DETAILS ---
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),

                // --- PRICE SECTION ---
                Row(
                  children: [
                    Text(
                      "\$${product.price}",
                      style: TextStyle(
                        // Use Primary color for the price to match your amber brand
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (product.oldPrice > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        "\$${product.oldPrice}",
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                          decoration: TextDecoration.lineThrough,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                // --- STOCK STATUS ---
                Text(
                  product.stockCount > 0 ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    // Use theme error color for 'Out of Stock'
                    color: product.stockCount > 0
                        ? Colors
                              .greenAccent[700] // Bright enough for both modes
                        : colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
