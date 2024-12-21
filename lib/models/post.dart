// models/post.dart

class Post {
  int? id;
  String title;
  String content;
  String? image;
  String status;
  int userId;

  Post({
    this.id,
    required this.title,
    required this.content,
    this.image,
    required this.status,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      image: json['image'] as String?,
      status: json['status'] as String,
      userId: json['user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'image': image,
      'status': status,
      'user_id': userId,
    };
  }
}
