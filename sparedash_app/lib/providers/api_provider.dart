import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiProvider with ChangeNotifier {
  List<dynamic> _users = [];
  List<dynamic> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get users => _users;
  List<dynamic> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ============ FETCH USERS FROM API ============

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await ApiService.getUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = ApiService.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ FETCH POSTS FROM API ============

  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await ApiService.getPosts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = ApiService.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ CREATE NEW POST ============

  Future<bool> createPost(String title, String body) async {
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> newPost = {
        'title': title,
        'body': body,
        'userId': 1,
      };

      await ApiService.createPost(newPost);
      await fetchPosts(); // Refresh list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ApiService.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============ UPDATE POST ============

  Future<bool> updatePost(int postId, String title, String body) async {
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> updatedPost = {
        'title': title,
        'body': body,
        'userId': 1,
      };

      await ApiService.updatePost(postId, updatedPost);
      await fetchPosts(); // Refresh list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ApiService.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============ DELETE POST ============

  Future<bool> deletePost(int postId) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await ApiService.deletePost(postId);
      if (success) {
        await fetchPosts(); // Refresh list
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = ApiService.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============ CLEAR ERROR ============

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============ REFRESH ALL DATA ============

  Future<void> refreshAllData() async {
    await Future.wait([
      fetchUsers(),
      fetchPosts(),
    ]);
  }
}