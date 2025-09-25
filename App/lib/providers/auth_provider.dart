import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  // Your Flask API endpoint
  static const String _apiBaseUrl = 'https://atithiverse.qzz.io';

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize auth state from saved preferences
  Future<void> initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null) {
        _user = json.decode(userData);
        _isAuthenticated = true;
        notifyListeners();

        // Verify with server
        await _verifyAuthWithServer();
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  Future<void> _verifyAuthWithServer() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/user'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'AtithiVerse-Flutter-App/1.0',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        // If verification fails, logout
        await logout();
      }
    } catch (e) {
      print('Auth verification failed: $e');
      // Don't logout on network errors, keep local auth state
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔐 Attempting login to: $_apiBaseUrl/api/login');
      print('📧 Email: $email');

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'AtithiVerse-Flutter-App/1.0',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      print('🔐 Login response status: ${response.statusCode}');
      print('🔐 Login response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _isAuthenticated = true;
          _user = data['user'];

          // Save to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', json.encode(_user));

          print('✅ Login successful for user: ${_user!['name']}');

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = data['message'] ?? 'Login failed';
          print('❌ Login failed: $_error');
        }
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Login failed with status ${response.statusCode}';
        print('❌ Login failed with status ${response.statusCode}: $_error');
      }
    } on SocketException catch (e) {
      print('❌ Network error during login: $e');
      _error = 'No internet connection. Please check your network.';
    } on http.ClientException catch (e) {
      print('❌ HTTP client error during login: $e');
      _error = 'Network error. Please try again.';
    } on TimeoutException catch (e) {
      print('❌ Timeout during login: $e');
      _error = 'Request timed out. Please try again.';
    } catch (e) {
      print('❌ Unexpected error during login: $e');
      _error = 'Login failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? country,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📝 Attempting registration to: $_apiBaseUrl/api/register');
      print('📧 Email: $email');

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'AtithiVerse-Flutter-App/1.0',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone ?? '',
          'country': country ?? 'India',
        }),
      ).timeout(const Duration(seconds: 15));

      print('📝 Registration response status: ${response.statusCode}');
      print('📝 Registration response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          print('✅ Registration successful');
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = data['message'] ?? 'Registration failed';
          print('❌ Registration failed: $_error');
        }
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Registration failed with status ${response.statusCode}';
        print('❌ Registration failed with status ${response.statusCode}: $_error');
      }
    } on SocketException catch (e) {
      print('❌ Network error during registration: $e');
      _error = 'No internet connection. Please check your network.';
    } on http.ClientException catch (e) {
      print('❌ HTTP client error during registration: $e');
      _error = 'Network error. Please try again.';
    } on TimeoutException catch (e) {
      print('❌ Timeout during registration: $e');
      _error = 'Request timed out. Please try again.';
    } catch (e) {
      print('❌ Unexpected error during registration: $e');
      _error = 'Registration failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      // Call logout API
      await http.post(
        Uri.parse('$_apiBaseUrl/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'AtithiVerse-Flutter-App/1.0',
        },
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      print('Logout API error: $e');
      // Continue with local logout even if API fails
    }

    // Clear local state
    _isAuthenticated = false;
    _user = null;
    _error = null;

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
