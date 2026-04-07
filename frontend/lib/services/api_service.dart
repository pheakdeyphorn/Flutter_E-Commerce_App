import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Base URLs matching your server.js and route registrations
  static const String productUrl = "http://10.0.2.2:5002/api/products";
  static const String orderUrl = "http://10.0.2.2:5002/api/orders";
  static const String authUrl = "http://10.0.2.2:5002/api/auth";
  static const String categoryUrl = "http://10.0.2.2:5002/api/categories";
  static const String brandUrl = "http://10.0.2.2:5002/api/brands";

  // 1. AUTHENTICATION: Login
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
      return response.statusCode == 201;
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
        return (data['wallet_balance'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // 5. HISTORY: Get User Orders
  static Future<List<dynamic>> getUserOrders(String userId) async {
    try {
      final response = await http.get(Uri.parse("$orderUrl/user/$userId"));
      return response.statusCode == 200 ? json.decode(response.body) : [];
    } catch (e) {
      return [];
    }
  }

  // 6. ទាញយក Categories
  static Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(categoryUrl));
      return response.statusCode == 200 ? json.decode(response.body) : [];
    } catch (e) {
      return [];
    }
  }

  // 7. ទាញយក Brands
  static Future<List<dynamic>> fetchBrands() async {
    try {
      final response = await http.get(Uri.parse(brandUrl));
      return response.statusCode == 200 ? json.decode(response.body) : [];
    } catch (e) {
      return [];
    }
  }

  // ៨. PROFILE: ទាញទិន្នន័យ User ម្នាក់ៗមកបង្ហាញ
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse("$authUrl/profile/$userId"));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint("Error: $e");
      return null;
    }
  }

  // ៩. PROFILE: កែប្រែទិន្នន័យ User
  static Future<bool> updateUserProfile(
    String userId,
    String name,
    String email,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$authUrl/update/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
