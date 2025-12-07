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
  final int userId;
  final String authorName;
  final List<String> authorBadges; // 작성자 뱃지 목록
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int viewCount;
  final bool isLiked;

  PostModel({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorBadges = const [],
    required this.content,
    required this.viewCount,
    required this.likeCount,
    this.isLiked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'authorName': authorName,
      'authorBadges': authorBadges,
      'content': content,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    // Backend의 user 객체에서 작성자 정보 추출
    final user = map['user'];
    final String authorName = user != null ? user['nickname'] ?? 'Unknown' : 'Unknown';
    final List<String> authorBadges = user != null && user['badges'] != null
        ? List<String>.from(user['badges'])
        : [];

    return PostModel(
      id: map['id'],
      userId: user?['id'] ?? 0,
      authorName: authorName,
      authorBadges: authorBadges,
      content: map['content'] ?? '',
      viewCount: map['viewCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source));
}
