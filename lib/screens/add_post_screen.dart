import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../utils/string_extensions.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String _title = '';
  String _content = '';
  String? _image;
  String _status = 'published';
  int _categoryId = 1;
  int _userId = 1;
  int? _tagId;

  void _savePost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Post newPost = Post(
        title: _title,
        content: _content,
        image: _image,
        status: _status,
        categoryId: _categoryId,
        userId: _userId,
        tagId: _tagId,
      );

      try {
        await _apiService.createPost(newPost);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post created successfully')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title, color: Colors.blue),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                    onSaved: (value) => _title = value!,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description, color: Colors.blue),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Content is required';
                      }
                      return null;
                    },
                    onSaved: (value) => _content = value!,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Image URL (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.image, color: Colors.blue),
                    ),
                    onSaved: (value) => _image = value,
                  ),
                  if (_image != null && _image!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Image.network(
                        _image!,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(
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
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Category ID',
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.category, color: Colors.blueAccent),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return 'Valid category ID is required';
                      }
                      return null;
                    },
                    onSaved: (value) => _categoryId = int.parse(value!),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'User ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return 'Valid user ID is required';
                      }
                      return null;
                    },
                    onSaved: (value) => _userId = int.parse(value!),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tag ID (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag, color: Colors.blueAccent),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _tagId = value != null && value.isNotEmpty
                          ? int.tryParse(value)
                          : null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _savePost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      'Save Post',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
