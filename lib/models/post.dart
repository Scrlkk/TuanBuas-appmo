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
      id: json['id'],
      title: json['title'],
      content: json['content'],
      image: json['image'],
      status: json['status'],
      categoryId: json['category_id'],
      userId: json['user_id'],
      tagId: json['tag_id'],
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
