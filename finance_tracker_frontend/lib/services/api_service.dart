import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3001';  // Update with actual backend URL

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      }
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': email,
          'email': email,
          'password': password,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<bool> addTransaction({
    required String category,
    required String type,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.post(
        Uri.parse('$baseUrl/transactions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'category': category,
          'type': type,
          'amount': amount,
          'description': note,
          'date': date.toIso8601String(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Add transaction error: $e');
      return false;
    }
  }

  Future<bool> editTransaction({
    required int id,
    required String category,
    required String type,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.put(
        Uri.parse('$baseUrl/transactions/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'category': category,
          'type': type,
          'amount': amount,
          'description': note,
          'date': date.toIso8601String(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Edit transaction error: $e');
      return false;
    }
  }

  Future<bool> addBudget({
    required String category,
    required double limit,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.post(
        Uri.parse('$baseUrl/budgets/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'category': category,
          'amount': limit,
          'period': 'monthly',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Add budget error: $e');
      return false;
    }
  }

  Future<bool> editBudget({
    required int id,
    required String category,
    required double limit,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.put(
        Uri.parse('$baseUrl/budgets/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'category': category,
          'amount': limit,
          'period': 'monthly',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Edit budget error: $e');
      return false;
    }
  }
}
