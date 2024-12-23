import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_services.dart';
import '../models/category.dart';
import '../models/post.dart';

class PostFormScreen extends StatefulWidget {
  final int? postId;
  @override
  final Key? key;

  const PostFormScreen({this.postId, this.key}) : super(key: key);

  @override
  _PostFormScreenState createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? content;
  int? categoryId;
  String? tags;
  String status = 'published';
  bool isLoading = false;
  late Future<List<Category>> categoriesFuture;
  File? selectedImage; // Untuk menyimpan file gambar yang dipilih
  final ImagePicker _imagePicker = ImagePicker();

  // Objek Post untuk menyimpan data post
  Post? postData;

  @override
  void initState() {
    super.initState();
    categoriesFuture = apiService.fetchCategories();
    if (widget.postId != null) {
      _fetchPostDetails();
    }
  }

  Future<void> _fetchPostDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      final posts = await apiService.fetchPosts();
      postData = posts.firstWhere((post) => post.id == widget.postId);
      if (mounted) {
        setState(() {
          title = postData!.title;
          content = postData!.content;
          categoryId = postData!.category_id;
          tags = postData!.tags?.join(', ');
          status = postData!.status;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch post details')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      String? tagsString =
          tags?.split(',').map((e) => e.trim()).join(', ') ?? '';

      final postDataToSend = {
        'title': title!,
        'content': content!,
        'status': status,
        'category_id': categoryId.toString(),
        'tags': tagsString,
      };

      if (widget.postId == null) {
        // Post baru
        await apiService.createPost(postDataToSend, imageFile: selectedImage);
      } else {
        // Update post
        await apiService.updatePost(widget.postId!, postDataToSend,
            imageFile: selectedImage);
      }

      if (mounted) {
        Navigator.popUntil(context, ModalRoute.withName('/post_list'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save post')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.postId == null ? "Add Post" : "Edit Post",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<Category>>(
                future: categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Failed to load categories",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No categories available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  } else {
                    final categories = snapshot.data!;
                    return Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              initialValue: title,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                labelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onSaved: (value) => title = value,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Title is required'
                                      : null,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              initialValue: content,
                              decoration: InputDecoration(
                                labelText: 'Content',
                                labelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              maxLines: 5,
                              onSaved: (value) => content = value,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Content is required'
                                      : null,
                            ),
                            SizedBox(height: 10),
                            DropdownButtonFormField<int>(
                              value: categoryId,
                              items: categories.map((category) {
                                return DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  categoryId = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Category',
                                labelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              validator: (value) =>
                                  value == null ? 'Category is required' : null,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              initialValue: tags,
                              decoration: InputDecoration(
                                labelText: 'Tags (comma separated)',
                                labelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onSaved: (value) => tags = value,
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Status',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black)),
                                DropdownButton<String>(
                                  value: status,
                                  items: [
                                    DropdownMenuItem(
                                      value: 'published',
                                      child: Text('Published'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'archived',
                                      child: Text('Archived'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      status = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            if (selectedImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(selectedImage!, height: 100),
                              ),
                            ElevatedButton(
                              onPressed: _pickImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                "Pick Image",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                widget.postId == null
                                    ? "Create Post"
                                    : "Update Post",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }
}
