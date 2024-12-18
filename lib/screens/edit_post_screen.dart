import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../utils/string_extensions.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({Key? key, required this.post}) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late String _title;
  late String _content;
  String? _image;
  late String _status;
  late int _categoryId;
  late int _userId;
  int? _tagId;

  @override
  void initState() {
    super.initState();
    _title = widget.post.title;
    _content = widget.post.content;
    _image = widget.post.image;
    _status = widget.post.status;
    _categoryId = widget.post.categoryId;
    _userId = widget.post.userId;
    _tagId = widget.post.tagId;
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
        categoryId: _categoryId,
        userId: _userId,
        tagId: _tagId,
      );

      try {
        await _apiService.updatePost(widget.post.id!, updatedPost);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post updated successfully')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update post: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
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
                    initialValue: _title,
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
                    initialValue: _content,
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
                    initialValue: _image,
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
                    initialValue: _categoryId.toString(),
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
                    initialValue: _userId.toString(),
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
                    initialValue: _tagId?.toString(),
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
                    onPressed: _updatePost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      'Update Post',
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
