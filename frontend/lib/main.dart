import 'package:flutter/material.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/user_provider.dart'; // Import this
import 'package:frontend/screens/login_screen.dart'; // Import this
import 'package:frontend/screens/main_wrapper_screen.dart';
import 'package:frontend/theme/style.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // Add UserProvider to manage the real MongoDB _id globally
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Listen for changes in the UserProvider
    final userProvider = Provider.of<UserProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pheakdey Computer Store',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // AUTH GATE: If no userId exists, force LoginScreen.
      // Otherwise, proceed to MainWrapperScreen
      home: userProvider.userId == null
          ? const LoginScreen()
          : const MainWrapperScreen(),

      routes: {
        '/main': (context) => const MainWrapperScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
