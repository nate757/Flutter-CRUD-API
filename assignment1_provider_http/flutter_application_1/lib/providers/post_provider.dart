import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/api_service.dart';

enum ViewState { idle, loading, error }

class PostProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // ── State ───────────────────────────────────────────────────────────────────
  List<Post> _posts = [];
  ViewState _state = ViewState.idle;
  String _errorMessage = '';
  bool _isSubmitting = false;

  /// IDs of posts created locally this session.
  /// JSONPlaceholder returns 500 for PUT/DELETE on id > 100,
  /// so we manage these entirely on the client side.
  final Set<int> _localIds = {};

  // ── Getters ─────────────────────────────────────────────────────────────────
  List<Post> get posts => List.unmodifiable(_posts);
  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;

  // ── Fetch all posts ─────────────────────────────────────────────────────────
  Future<void> fetchPosts() async {
    _setState(ViewState.loading);
    try {
      _posts = await _apiService.fetchPosts();
      _setState(ViewState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Create ──────────────────────────────────────────────────────────────────
  Future<bool> createPost({
    required String title,
    required String body,
  }) async {
    _setSubmitting(true);
    try {
      final serverPost = await _apiService.createPost(
        userId: 1,
        title: title,
        body: body,
      );

      // JSONPlaceholder always echoes back id=101. To avoid duplicate key
      // collisions when creating multiple posts, generate a unique local id.
      final uniqueId = DateTime.now().millisecondsSinceEpoch;
      final newPost = serverPost.copyWith(id: uniqueId);

      _localIds.add(uniqueId);
      _posts.insert(0, newPost);
      _setSubmitting(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setSubmitting(false);
      return false;
    }
  }

  // ── Update ──────────────────────────────────────────────────────────────────
  Future<bool> updatePost(Post post) async {
    _setSubmitting(true);
    try {
      Post updated;

      if (_localIds.contains(post.id)) {
        // Locally-created post: skip the API call (server would 500)
        // and update in-memory directly.
        updated = post;
      } else {
        updated = await _apiService.updatePost(post);
      }

      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) _posts[index] = updated;
      _setSubmitting(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setSubmitting(false);
      return false;
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────────────
  Future<bool> deletePost(int id) async {
    _setSubmitting(true);
    try {
      if (!_localIds.contains(id)) {
        // Only call the API for real server posts (id 1-100)
        await _apiService.deletePost(id);
      }
      _posts.removeWhere((p) => p.id == id);
      _localIds.remove(id);
      _setSubmitting(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setSubmitting(false);
      return false;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  void _setState(ViewState s) {
    _state = s;
    if (s != ViewState.error) _errorMessage = '';
    notifyListeners();
  }

  void _setError(String msg) {
    _state = ViewState.error;
    _errorMessage = msg.replaceFirst('Exception: ', '');
    notifyListeners();
  }

  void _setSubmitting(bool val) {
    _isSubmitting = val;
    notifyListeners();
  }

  void clearError() {
    if (_state == ViewState.error) _setState(ViewState.idle);
  }
}