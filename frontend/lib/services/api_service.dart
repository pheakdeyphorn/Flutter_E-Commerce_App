import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Base URLs matching your server.js and route registrations
  static const String productUrl = "http://10.0.2.2:5001/api/products";
  static const String orderUrl = "http://10.0.2.2:5001/api/orders";
  static const String authUrl = "http://10.0.2.2:5001/api/auth";

  // 1. AUTHENTICATION: Login
  // Matches your authController.loginUser logic
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$authUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        // Returns _id, name, email, wallet_balance, and token
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        debugPrint("Login Failed: ${errorData['message']}");
        return null;
      }
    } catch (e) {
      debugPrint("Login Network Error: $e");
      return null;
    }
  }

  // 2. PRODUCTS: Fetch all items
  // Maps MongoDB _id to Flutter id
  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(productUrl));

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (err) {
      throw Exception("Failed to connect to backend: $err");
    }
  }

  // 3. ORDERS: Process Checkout
  static Future<bool> checkout({
    required String userId,
    required double totalPrice,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$orderUrl/checkout"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "total_price": totalPrice,
          "items": items,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        debugPrint("Checkout Failed: ${errorData['message']}");
        return false;
      }
    } catch (err) {
      debugPrint("Checkout Connection Error: $err");
      return false;
    }
  }

  // 4. WALLET: Get Current Balance
  static Future<double> getBalance(String userId) async {
    try {
      final response = await http.get(Uri.parse("$orderUrl/balance/$userId"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Matches the wallet_balance field in your User model
        return (data['wallet_balance'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      debugPrint("Balance Fetch Error: $e");
      return 0.0;
    }
  }

  // 5. HISTORY: Get User Orders
  static Future<List<dynamic>> getUserOrders(String userId) async {
    try {
      final response = await http.get(Uri.parse("$orderUrl/user/$userId"));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Order History Error: $e");
      return [];
    }
  }
}
