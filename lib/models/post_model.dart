import 'dart:convert';

class UserSummary {
  final int id;
  final String ssoQualifier;
  final List<String> badges;

  UserSummary({
    required this.id,
    required this.ssoQualifier,
    required this.badges,
  });

  factory UserSummary.fromMap(Map<String, dynamic> map) {
    return UserSummary(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      ssoQualifier: map['ssoQualifier'] ?? '',
      badges: map['badges'] != null 
          ? List<String>.from(map['badges']) 
          : [],
    );
  }
}

class PostModel {
  final int id;
  final String content;
  final UserSummary? user;
  final DateTime createdAt;
  final int likeCount;
  final int viewCount;

  PostModel({
    required this.id,
    required this.content,
    this.user,
    required this.createdAt,
    this.likeCount = 0,
    this.viewCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'user': user, // This might need to be serialized properly if sent back
      'createdAt': createdAt.toIso8601String(),
      'likeCount': likeCount,
      'viewCount': viewCount,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      content: map['content'] ?? '',
      user: map['user'] != null ? UserSummary.fromMap(map['user']) : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      likeCount: map['likeCount'] ?? 0,
      viewCount: map['viewCount'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source));
      
  // Helper to get display name
  String get authorName => user?.ssoQualifier ?? 'Unknown';
}
