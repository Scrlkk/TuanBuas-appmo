// services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  // It's better to use a configurable base URL, possibly from environment variables or config files.
  final String baseUrl = 'http://192.168.187.25:8000/api/posts';

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  Future<Post> createPost(Post post) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(post.toJson()),
    );
    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to create post: ${response.body}');
    }
  }

  Future<Post> updatePost(int id, Post post) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(post.toJson()),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to update post: ${response.body}');
    }
  }

  Future<void> deletePost(int id, {String? imageUrl}) async {
    // Delete image if it exists
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await deleteImage(imageUrl);
    }

    // Delete post
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete post: ${response.statusCode}');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    // Implement actual image deletion logic here.
    // For example, if using AWS S3, use the AWS SDK to delete the file.
    // Alternatively, call an API endpoint that handles image deletion.

    // Placeholder implementation:
    print('Deleting image: $imageUrl');
    // Simulate deletion delay
    await Future.delayed(const Duration(seconds: 1));
  }
}
