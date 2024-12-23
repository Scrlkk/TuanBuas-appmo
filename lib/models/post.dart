class Post {
  final int id;
  final String title;
  final String content;
  final int category_id;
  final List<String>? tags; // List of tag names
  final String status;
  final String? imageUrl;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category_id,
    this.tags,
    required this.status,
    this.imageUrl,
  });

  // Factory constructor for creating a new Post object from a JSON map
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] is int
          ? json['id']
          : int.parse(json['id'].toString()), // Pastikan 'id' berupa int
      title: json['title'],
      content: json['content'],
      category_id: json['category_id'] is int
          ? json['category_id']
          : int.parse(
              json['category_id'].toString()), // Konversi 'category_id' ke int
      tags: json['tags'] != null
          ? (json['tags'] as List<dynamic>)
              .map((tag) => tag is Map && tag['name'] != null
                  ? tag['name'].toString()
                  : tag.toString())
              .toList()
          : null,
      status: json['status'] ?? 'published',
      imageUrl: json['image_url'],
    );
  }

  // Convert the Post object to a Map, to send data in requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category_id': category_id,
      'tags': tags, // Assuming tags is a List<String>
      'status': status,
      'image_url': imageUrl,
    };
  }
}
