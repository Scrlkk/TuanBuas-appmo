import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../models/post.dart';
import '../models/category.dart';
import 'post_form_screen.dart';
import 'post_view_screen.dart'; // Import halaman detail post

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Post>> postsFuture;
  late Future<List<Category>> categoriesFuture;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    postsFuture = apiService.fetchPosts();
    categoriesFuture = apiService.fetchCategories();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      categories = await categoriesFuture;
      setState(() {}); // Update UI after categories are loaded
    } catch (e) {
      // Handle error appropriately
      print("Error loading categories: $e");
    }
  }

  String _getCategoryName(int categoryId) {
    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category(id: 0, name: 'Unknown'),
    );
    return category.name;
  }

  // Function to refresh the list of posts
  Future<void> _refreshPosts() async {
    setState(() {
      postsFuture = apiService.fetchPosts(); // Fetch latest posts
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define a primary color for the app
    final Color primaryColor = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Blog Posts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 4,
      ),
      body: FutureBuilder<List<Post>>(
        future: postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching posts
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Display an error message if fetching fails
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show a message if no posts are available
            return RefreshIndicator(
              onRefresh: _refreshPosts,
              child: ListView(
                padding: EdgeInsets.only(bottom: 80), // Prevent overlap
                children: [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      "No posts available",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final posts = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshPosts,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16)
                  .copyWith(bottom: 80), // Added bottom padding
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final categoryName = _getCategoryName(post.category_id);

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image section
                      if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            Uri.parse(post.imageUrl!).toString(),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
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
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                    color: primaryColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Post Title
                            Text(
                              post.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Post Status
                            Row(
                              children: [
                                Icon(
                                  post.status == 'published'
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  color: post.status == 'published'
                                      ? Colors.green
                                      : Colors.orange,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Status: ${StringCasingExtension(post.status).capitalize()}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: post.status == 'published'
                                        ? Colors.green[700]
                                        : Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Post Category
                            Row(
                              children: [
                                Icon(
                                  Icons.category,
                                  color: Colors.blueGrey,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Category: $categoryName",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            // Post Tags
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: (post.tags ?? [])
                                  .map(
                                    (tag) => Chip(
                                      label: Text(
                                        tag,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
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
                          ],
                        ),
                      ),
                      Divider(height: 1),
                      // Action Buttons
                      OverflowBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              // Navigate to PostViewScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PostViewScreen(post: post),
                                ),
                              );
                            },
                            icon: Icon(Icons.visibility, color: primaryColor),
                            label: Text(
                              "View",
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PostFormScreen(postId: post.id),
                                ),
                              );
                              if (result == true) _refreshPosts();
                            },
                            icon: Icon(Icons.edit, color: Colors.orange),
                            label: Text(
                              "Edit",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Delete Post"),
                                  content: Text(
                                      "Are you sure you want to delete this post?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await apiService.deletePost(post.id);
                                _refreshPosts();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Post deleted successfully"),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                            label: Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      // Replace FloatingActionButton with BottomAppBar
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Add Button
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostFormScreen(),
                    ),
                  );
                  if (result == true) _refreshPosts();
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  "Add Post",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension method to capitalize strings
extension StringCasingExtension on String {
  String capitalize() =>
      this.isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
