// models/post.dart

class Post {
  int? id;
  String title;
  String content;
  String? image;
  String status;
  int categoryId;
  int userId;
  int? tagId;

  Post({
    this.id,
    required this.title,
    required this.content,
    this.image,
    required this.status,
    required this.categoryId,
    required this.userId,
    this.tagId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      image: json['image'] as String?,
      status: json['status'] as String,
      categoryId: json['category_id'] as int,
      userId: json['user_id'] as int,
      tagId: json['tag_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'image': image,
      'status': status,
      'category_id': categoryId,
      'user_id': userId,
      'tag_id': tagId,
    };
  }
}
