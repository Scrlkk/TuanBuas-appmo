import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../utils/string_extensions.dart';
import 'edit_post_screen.dart'; // Import EditPostScreen

class PostListScreen extends StatefulWidget {
  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _postListFuture;

  @override
  void initState() {
    super.initState();
    _postListFuture = _apiService.getPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postListFuture = _apiService.getPosts();
    });
  }

  Future<void> _deletePost(int? postId, String? imageUrl) async {
    if (postId != null) {
      try {
        // Menghapus post dan gambar terkait jika postId tidak null
        await _apiService.deletePost(postId, imageUrl: imageUrl);
        // Setelah berhasil, refresh daftar post
        _refreshPosts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post ID is null, cannot delete post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bloggers'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/addPost')
                .then((_) => _refreshPosts()),
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _postListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts available.'));
          }

          final posts = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshPosts,
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: post.image != null
                        ? Image.network(
                            post.image!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image_not_supported),
                          )
                        : Icon(Icons.image, size: 60, color: Colors.grey),
                    title: Text(
                      post.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          post.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Status: ${post.status.capitalize()}',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Navigate to EditPostScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditPostScreen(post: post),
                              ),
                            ).then((_) =>
                                _refreshPosts()); // Refresh list after edit
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deletePost(
                                post.id, post.image); // Delete post and image
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
