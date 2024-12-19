// screens/detail_post_screen.dart

import 'package:flutter/material.dart';
import '../models/post.dart';
import '../utils/string_extensions.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  Widget _buildImage() {
    if (post.image != null && post.image!.isNotEmpty) {
      return Image.network(
        post.image!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.image_not_supported,
          size: 100,
          color: Colors.grey,
        ),
      );
    }
    return Icon(Icons.image, size: 100, color: Colors.grey);
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity,
              height: 200,
              child: _buildImage(),
            ),
            SizedBox(height: 20),
            // Title
            Text(
              post.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            // Status
            _buildDetailRow(
              'Status',
              post.status.capitalize(),
              color: Colors.blueGrey,
            ),
            // Category ID
            _buildDetailRow(
              'Category ID',
              post.categoryId.toString(),
            ),
            // User ID
            _buildDetailRow(
              'User ID',
              post.userId.toString(),
            ),
            // Tag ID
            if (post.tagId != null)
              _buildDetailRow(
                'Tag ID',
                post.tagId.toString(),
              ),
            Divider(height: 32, thickness: 1),
            // Content
            Text(
              post.content,
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
