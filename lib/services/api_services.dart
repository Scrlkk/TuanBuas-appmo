import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/post.dart';

class ApiService {
  final String baseUrl =
      "http://192.168.1.104:8000/api"; // Ganti dengan URL API Laravel Anda

  // Mengambil daftar kategori
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      final List<dynamic> categoryData = json.decode(response.body)['data'];
      return categoryData.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch categories");
    }
  }

  // Mengambil daftar post
  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> postData = json.decode(response.body)['data'];
      return postData.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch posts");
    }
  }

  // Fungsi untuk membuat post dengan dukungan gambar
  Future<Post> createPost(Map<String, dynamic> postData,
      {File? imageFile}) async {
    var uri = Uri.parse('$baseUrl/posts');

    var request = http.MultipartRequest('POST', uri);

    // Menambahkan data teks ke form-data
    request.fields['title'] = postData['title'];
    request.fields['content'] = postData['content'];
    request.fields['category_id'] = postData['category_id'];
    request.fields['tags'] = postData['tags'] ?? '';
    request.fields['status'] = postData['status'];

    // Menambahkan file gambar jika ada
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    try {
      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return Post.fromJson(json.decode(responseBody)['data']);
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception(
            "Failed to create post: ${response.statusCode}, $responseBody");
      }
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  // Fungsi untuk memperbarui post dengan dukungan gambar
  Future<Post> updatePost(int postId, Map<String, dynamic> postData,
      {File? imageFile}) async {
    var uri = Uri.parse('$baseUrl/posts/$postId');

    var request = http.MultipartRequest('POST', uri);
    request.fields['_method'] =
        'PUT'; // Laravel mendukung method spoofing dengan _method

    // Menambahkan data teks ke form-data
    request.fields['title'] = postData['title'];
    request.fields['content'] = postData['content'];
    request.fields['category_id'] = postData['category_id'];
    request.fields['tags'] = postData['tags'] ?? '';
    request.fields['status'] = postData['status'];

    // Menambahkan file gambar jika ada
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return Post.fromJson(json.decode(responseBody)['data']);
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception(
            "Failed to update post: ${response.statusCode}, $responseBody");
      }
    } catch (e) {
      throw Exception("Error updating post: $e");
    }
  }

  // Menghapus post
  Future<void> deletePost(int postId) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$postId'));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete post");
    }
  }
}
