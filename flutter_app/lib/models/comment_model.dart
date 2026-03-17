class CommentModel {
  final int? commentId;
  final String content;
  final String userNum;
  final String targetType;
  final String targetId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommentModel({
    this.commentId,
    required this.content,
    required this.userNum,
    required this.targetType,
    required this.targetId,
    this.createdAt,
    this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'],
      content: json['content'],
      userNum: json['userNum'],
      targetType: json['targetType'],
      targetId: json['targetId'].toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "content": content,
      "userNum": userNum,
      "targetType": targetType,
      "targetId": targetId,
    };
  }
}