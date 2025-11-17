import 'package:flutter/foundation.dart';

@immutable
class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      postId: json['postId'] as int,
      userId: json['userId'] as int,
      content: json['content'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  final int id;
  final int postId;
  final int userId;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
