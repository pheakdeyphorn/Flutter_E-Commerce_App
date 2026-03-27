import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add Provider
import 'package:frontend/providers/user_provider.dart'; // Add UserProvider
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Access the real user data from your Provider
    final userProvider = Provider.of<UserProvider>(context);
    final String? userId = userProvider.userId;
    final String name = userProvider.userName ?? "Guest User";
    final String email = userProvider.userEmail ?? "No email found";

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: userId == null
          ? const Center(child: Text("Please log in to view profile"))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // --- USER AVATAR SECTION ---
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // DISPLAY REAL NAME FROM DB
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // DISPLAY REAL EMAIL FROM DB
                  Text(
                    email,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),

                  const SizedBox(height: 30),

                  // --- WALLET BALANCE CARD ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FutureBuilder<double>(
                      // Uses the real MongoDB _id from your Login
                      future: ApiService.getBalance(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        }

                        final balance = snapshot.data ?? 0.0;

                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Wallet Balance",
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "\$${balance.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.account_balance_wallet,
                                color: colorScheme.onPrimary,
                                size: 40,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(thickness: 1),

                  // --- MENU OPTIONS ---
                  ListTile(
                    leading: Icon(Icons.history, color: colorScheme.primary),
                    title: const Text("Order History"),
                    subtitle: const Text("View your past purchases"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderHistoryScreen(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: Icon(Icons.settings, color: colorScheme.outline),
                    title: const Text("Settings"),
                    subtitle: const Text("App preferences and account"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  // --- LOGOUT BUTTON ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // Call the logout function in Provider to clear the session
                          userProvider.logout();
                          // Redirect back to LoginScreen
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
