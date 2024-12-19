// screens/edit_post_screen.dart

import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../utils/string_extensions.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _imageController = TextEditingController();

  late String _title;
  late String _content;
  String? _image;
  late String _status;
  final int _userId = 1; // Fixed to 1

  @override
  void initState() {
    super.initState();
    _title = widget.post.title;
    _content = widget.post.content;
    _image = widget.post.image;
    _status = widget.post.status;
    _imageController.text = _image ?? '';
    _imageController.addListener(_onImageUrlChanged);
  }

  @override
  void dispose() {
    _imageController.removeListener(_onImageUrlChanged);
    _imageController.dispose();
    super.dispose();
  }

  void _onImageUrlChanged() {
    setState(() {
      _image = _imageController.text;
    });
  }

  void _updatePost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Post updatedPost = Post(
        id: widget.post.id,
        title: _title,
        content: _content,
        image: _image,
        status: _status,
        userId: _userId, // Set to 1
      );

      try {
        await _apiService.updatePost(widget.post.id!, updatedPost);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update post: $error')),
        );
      }
    }
  }

  Widget _buildImagePreview() {
    if (_image != null && _image!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Image.network(
          _image!,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 100, color: Colors.grey),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: Colors.blueAccent,
      ),
      body: GestureDetector(
        // Dismiss keyboard when tapping outside
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Title Field
                    TextFormField(
                      initialValue: _title,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title, color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                      onSaved: (value) => _title = value!.trim(),
                    ),
                    const SizedBox(height: 20),
                    // Content Field
                    TextFormField(
                      initialValue: _content,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description, color: Colors.blue),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Content is required';
                        }
                        return null;
                      },
                      onSaved: (value) => _content = value!.trim(),
                    ),
                    const SizedBox(height: 20),
                    // Image URL Field
                    TextFormField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image, color: Colors.blue),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    _buildImagePreview(),
                    const SizedBox(height: 20),
                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: ['published', 'archived']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.capitalize()),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        _status = value!;
                      }),
                    ),
                    const SizedBox(height: 30),
                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updatePost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Update Post',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
