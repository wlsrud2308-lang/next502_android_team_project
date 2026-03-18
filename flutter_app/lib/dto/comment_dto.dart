class CommentDto {
  final int commentId;
  final String content;
  final String nickname;
  final String targetType;
  final String targetId;
  final String createdAt;

  CommentDto({
    required this.commentId,
    required this.content,
    required this.nickname,
    required this.targetType,
    required this.targetId,
    required this.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      commentId: json['commentId'] ?? 0,
      content: json['content'] ?? '',
      nickname: json['nickname'] ?? '익명',
      targetType: json['targetType'] ?? '',
      targetId: json['targetId'] ?? '',
      createdAt: json['createdAt'] != null
          ? json['createdAt'].toString().split('T')[0]
          : '',
    );
  }
}