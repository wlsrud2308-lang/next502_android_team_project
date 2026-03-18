class CommentDto {
  final int commentId;
  final String content;
  final int userNum;
  final String nickname;
  final String targetType;
  final int targetId;
  final DateTime? createdAt;

  CommentDto({
    required this.commentId,
    required this.content,
    required this.userNum,
    required this.nickname,
    required this.targetType,
    required this.targetId,
    this.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return CommentDto(
      commentId: _toInt(json['commentId'] ?? json['comment_id']),
      content: json['content']?.toString() ?? '',

      userNum: _toInt(json['userNum'] ?? json['user_num'] ?? json['userNumber']),

      nickname: json['nickname']?.toString() ?? '익명',
      targetType: json['targetType']?.toString() ?? 'POST',

      targetId: _toInt(json['targetId'] ?? json['postId'] ?? json['post_id']),

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
      'nickname': nickname,
      'targetType': targetType,
      'targetId': targetId,
    };
  }
}