class CommentDto {
  final int commentId;
  final String content;
  final int userNum;
  final int postId;
  final String nickname;
  final String targetType;
  final int? targetId;
  final DateTime? createdAt;

  CommentDto({
    required this.commentId,
    required this.content,
    required this.userNum,
    required this.postId,
    required this.nickname,
    required this.targetType,
    this.targetId,
    this.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int? _toNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return CommentDto(
      commentId: _toInt(json['commentId'] ?? json['comment_id']),
      content: json['content']?.toString() ?? '',
      userNum: _toInt(json['userNum'] ?? json['user_num']),
      postId: _toInt(json['postId'] ?? json['post_id']),
      nickname: json['nickname']?.toString() ?? '익명',
      targetType: json['targetType']?.toString() ?? 'POST',
      targetId: _toNullableInt(json['targetId'] ?? json['target_id']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'content': content,
      'userNum': userNum,
      'postId': postId,
      'nickname': nickname,
      'targetType': targetType,
      'targetId': targetId,
    };
  }
}