import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _endpoint = '/posts';

  // ── READ (all) ──────────────────────────────────────────────────────────────
  Future<List<Post>> fetchPosts({int limit = 20}) async {
    final uri = Uri.parse('$_baseUrl$_endpoint?_limit=$limit');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts (${response.statusCode})');
    }
  }

  // ── READ (single) ───────────────────────────────────────────────────────────
  Future<Post> fetchPost(int id) async {
    final uri = Uri.parse('$_baseUrl$_endpoint/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Post not found (${response.statusCode})');
    }
  }

  // ── CREATE ──────────────────────────────────────────────────────────────────
  Future<Post> createPost({
    required int userId,
    required String title,
    required String body,
  }) async {
    final uri = Uri.parse('$_baseUrl$_endpoint');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'userId': userId, 'title': title, 'body': body}),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create post (${response.statusCode})');
    }
  }

  Future<Post> updatePost(Post post) async {
    final uri = Uri.parse('$_baseUrl$_endpoint/${post.id}');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(post.toJson()),
    );

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update post (${response.statusCode})');
    }
  }

  Future<void> deletePost(int id) async {
    final uri = Uri.parse('$_baseUrl$_endpoint/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post (${response.statusCode})');
    }
  }
}