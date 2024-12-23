import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../services/api_services.dart';

class PostViewScreen extends StatefulWidget {
  final Post post;

  const PostViewScreen({required this.post, super.key});

  @override
  _PostViewScreenState createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  final ApiService apiService = ApiService();
  late Future<Category?> categoryFuture;

  @override
  void initState() {
    super.initState();
    categoryFuture = _fetchCategory();
  }

  Future<Category?> _fetchCategory() async {
    try {
      final categories = await apiService.fetchCategories();
      return categories.firstWhere(
        (cat) => cat.id == widget.post.category_id,
        orElse: () => Category(id: 0, name: 'Unknown'),
      );
    } catch (e) {
      print("Error fetching category: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.post.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Category?>(
          future: categoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Failed to load category",
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Text(
                  "Category not found",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            } else {
              final category = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post.imageUrl != null &&
                        widget.post.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: widget.post.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: primaryColor),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text(
                                    "Image not available",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported,
                                  size: 50, color: Colors.grey[600]),
                              SizedBox(height: 8),
                              Text(
                                "No Image",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    Text(
                      widget.post.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.category, color: Colors.blueGrey, size: 20),
                        SizedBox(width: 6),
                        Text(
                          "Category: ${category.name}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: (widget.post.tags ?? [])
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          widget.post.status == 'published'
                              ? Icons.check_circle
                              : Icons.pending,
                          color: widget.post.status == 'published'
                              ? Colors.green
                              : Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Status: ${widget.post.status.capitalize()}",
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.post.status == 'published'
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.post.content,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

// Extension method to capitalize strings
extension StringCasingExtensionViewScreen on String {
  String capitalize() =>
      this.isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
