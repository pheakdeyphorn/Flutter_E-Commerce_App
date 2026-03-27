import 'package:flutter/material.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/providers/user_provider.dart'; // Add UserProvider
import 'package:frontend/services/api_service.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // --- CHECKOUT LOGIC ---
  Future<void> _handleCheckout(BuildContext context, CartProvider cart) async {
    // 1. Get the real userId from the Provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? userId = userProvider.userId;

    if (userId == null) {
      _showStatusDialog(
        context,
        "Error",
        "You must be logged in to checkout.",
        Colors.orange,
      );
      return;
    }

    // Show a loading spinner while communicating with Node.js
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Format items to match your Order.js schema
      final List<Map<String, dynamic>> orderItems = cart.items.map((product) {
        return {
          "product_id": product.id,
          "quantity": 1,
          "price": product.price,
        };
      }).toList();

      // 3. Call the API Service using the REAL userId
      bool isSuccess = await ApiService.checkout(
        userId: userId,
        totalPrice: cart.totalAmount,
        items: orderItems,
      );

      // Close the loading spinner
      Navigator.pop(context);

      if (isSuccess) {
        // 4. Clear the local cart state on success
        cart.clearCart();

        _showStatusDialog(
          context,
          "Success!",
          "Your order has been placed and stock has been updated.",
          Colors.green,
        );
      } else {
        _showStatusDialog(
          context,
          "Checkout Failed",
          "Please check your wallet balance or stock availability.",
          Colors.red,
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      debugPrint("Checkout Exception: $e");
    }
  }

  void _showStatusDialog(
    BuildContext context,
    String title,
    String msg,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(color: color)),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Your cart")),
      body: cart.items.isEmpty
          ? const Center(child: Text("Your cart is empty!"))
          : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final product = cart.items[index];
                return ListTile(
                  title: Text(product.name),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                  subtitle: Text(
                    "\$${product.price}",
                    style: TextStyle(
                      color: themeColor.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => cart.removeFromCart(product),
                    icon: Icon(Icons.delete, color: themeColor.error),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeColor.surface,
          boxShadow: [
            BoxShadow(
              color: themeColor.brightness == Brightness.light
                  ? Colors.black12
                  : Colors.black54,
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total:", style: TextStyle(fontSize: 16)),
                  Text(
                    "\$${cart.totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: themeColor.primary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor.primary,
                  foregroundColor: themeColor.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: cart.items.isEmpty
                    ? null
                    : () => _handleCheckout(context, cart),
                child: const Text(
                  "Checkout",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
