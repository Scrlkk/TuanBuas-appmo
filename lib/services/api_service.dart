import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8000/api/posts';

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      return data.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts');
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
      throw Exception('Failed to create post');
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
      throw Exception('Failed to update post');
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
      throw Exception('Failed to delete post');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    // Logika untuk menghapus gambar, misalnya jika menggunakan AWS S3
    try {
      // Jika Anda menggunakan AWS S3, Anda dapat menggunakan AWS SDK untuk Flutter atau panggil endpoint API untuk menghapus gambar
      // Contoh:
      // await s3Service.deleteFile(imageUrl);

      // Untuk contoh ini, kita anggap gambar dihapus jika imageUrl ada
      print('Deleting image: $imageUrl');
      // Simulasi penghapusan gambar dari penyimpanan (cloud atau lokal)
    } catch (e) {
      print('Failed to delete image: $e');
      throw Exception('Failed to delete image');
    }
  }
}
