class CommentDto {
  final int commentId;
  final String content;
  final int userNum;
  final String nickname;
  final String targetType;
  final int targetId;
  final DateTime? createdAt; // String에서 DateTime?으로 변경

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
    return CommentDto(
      // 서버(Java)의 필드명이 commentId이므로 정확히 일치시켜야 함
      commentId: json['commentId'] ?? 0,
      content: json['content'] ?? '',
      userNum: json['userNum'] ?? 0,
      nickname: json['nickname'] ?? '익명',
      targetType: json['targetType'] ?? '',
      targetId: json['postId'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}