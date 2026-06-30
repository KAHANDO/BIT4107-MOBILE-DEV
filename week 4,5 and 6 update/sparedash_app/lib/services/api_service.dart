import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  static const String BASE_URL = 'https://jsonplaceholder.typicode.com';

  // Check internet connection
  static Future<bool> hasInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ============ HTTP GET REQUEST - Retrieve Users ============

  static Future<List<dynamic>> getUsers() async {
    try {
      // Check internet connection first
      bool isConnected = await hasInternetConnection();
      if (!isConnected) {
        throw Exception('No internet connection. Please check your network.');
      }

      print('📡 Making GET request to: $BASE_URL/users');

      final response = await http.get(
        Uri.parse('$BASE_URL/users'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout. Please try again.'),
      );

      print('📡 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);
        print('✅ Successfully fetched ${users.length} users');
        return users;
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found (404)');
      } else if (response.statusCode == 500) {
        throw Exception('Server error (500). Please try later.');
      } else {
        throw Exception('Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ GET Users Error: $e');
      rethrow;
    }
  }

  // ============ HTTP GET REQUEST - Get Posts ============

  static Future<List<dynamic>> getPosts() async {
    try {
      bool isConnected = await hasInternetConnection();
      if (!isConnected) {
        throw Exception('No internet connection. Please check your network.');
      }

      print('📡 Making GET request to: $BASE_URL/posts');

      final response = await http.get(
        Uri.parse('$BASE_URL/posts'),
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> posts = json.decode(response.body);
        print('✅ Successfully fetched ${posts.length} posts');
        return posts;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print('❌ GET Posts Error: $e');
      rethrow;
    }
  }

  // ============ HTTP POST REQUEST - Create Data ============

  static Future<Map<String, dynamic>> createPost(Map<String, dynamic> data) async {
    try {
      bool isConnected = await hasInternetConnection();
      if (!isConnected) {
        throw Exception('No internet connection');
      }

      print('📡 Making POST request to: $BASE_URL/posts');

      final response = await http.post(
        Uri.parse('$BASE_URL/posts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status code: ${response.statusCode}');

      if (response.statusCode == 201) {
        Map<String, dynamic> result = json.decode(response.body);
        print('✅ Post created successfully with ID: ${result['id']}');
        return result;
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ POST Error: $e');
      rethrow;
    }
  }

  // ============ HTTP PUT REQUEST - Update Data ============

  static Future<Map<String, dynamic>> updatePost(int postId, Map<String, dynamic> data) async {
    try {
      bool isConnected = await hasInternetConnection();
      if (!isConnected) {
        throw Exception('No internet connection');
      }

      print('📡 Making PUT request to: $BASE_URL/posts/$postId');

      final response = await http.put(
        Uri.parse('$BASE_URL/posts/$postId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Post updated successfully');
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update post: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ PUT Error: $e');
      rethrow;
    }
  }

  // ============ HTTP DELETE REQUEST - Delete Data ============

  static Future<bool> deletePost(int postId) async {
    try {
      bool isConnected = await hasInternetConnection();
      if (!isConnected) {
        throw Exception('No internet connection');
      }

      print('📡 Making DELETE request to: $BASE_URL/posts/$postId');

      final response = await http.delete(
        Uri.parse('$BASE_URL/posts/$postId'),
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Post deleted successfully');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('❌ DELETE Error: $e');
      return false;
    }
  }

  // ============ ERROR HANDLING UTILITIES ============

  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('No internet')) {
      return '📡 No internet connection. Please check your network and try again.';
    } else if (error.toString().contains('timeout')) {
      return '⏰ Connection timeout. Please check your internet speed and try again.';
    } else if (error.toString().contains('404')) {
      return '🔍 Requested resource not found (404).';
    } else if (error.toString().contains('500')) {
      return '⚠️ Server error (500). Please try again later.';
    } else if (error.toString().contains('SocketException')) {
      return '📡 Connection error. Please check your network.';
    } else {
      return '❌ An error occurred: ${error.toString()}';
    }
  }
}