import 'dart:convert';

class PostModel {
  final int id;
  final String title;
  final String content;
  final String? author; // Made nullable as it might not be in response
  final DateTime createdAt;
  final int likes;
  final int comments;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    this.author,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      author: map['author'], // Can be null
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source));
}
