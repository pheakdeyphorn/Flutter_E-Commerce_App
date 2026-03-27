import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this
import 'package:frontend/providers/user_provider.dart'; // Add this
import 'package:frontend/services/api_service.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  // REMOVED: final String userId = "698f58c8457d1dbd78b818b0";

  @override
  Widget build(BuildContext context) {
    // 1. Get the real logged-in userId from the Provider
    final userProvider = Provider.of<UserProvider>(context);
    final String? userId = userProvider.userId;

    return Scaffold(
      appBar: AppBar(title: const Text("Order History")),
      // 2. Check if userId exists before fetching
      body: userId == null
          ? const Center(child: Text("Please log in to see your orders."))
          : FutureBuilder<List<dynamic>>(
              // 3. Use the dynamic userId from Provider
              future: ApiService.getUserOrders(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No orders found yet."),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data!;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    // Use a try-catch or null check for safety with dates
                    final DateTime date = order['createdAt'] != null
                        ? DateTime.parse(order['createdAt'])
                        : DateTime.now();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.shopping_bag),
                        ),
                        title: Text(
                          "Order #${order['_id'].toString().substring(order['_id'].toString().length - 6)}",
                        ),
                        subtitle: Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(date),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${(order['total_price'] as num).toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              "Success",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
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
