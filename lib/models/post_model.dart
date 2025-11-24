import 'dart:convert';

class PostModel {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final int likes;
  final int comments;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
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
      id: map['id'],
      title: map['title'],
      content: map['content'],
      author: map['author'],
      createdAt: DateTime.parse(map['createdAt']),
      likes: map['likes'],
      comments: map['comments'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source));
}
