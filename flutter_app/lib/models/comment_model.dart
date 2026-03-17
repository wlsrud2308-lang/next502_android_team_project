class CommentModel {
  final int? commentId;
  final String content;
  final int userNum;
  final int postId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommentModel({
    this.commentId,
    required this.content,
    required this.userNum,
    required this.postId,
    this.createdAt,
    this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'],
      content: json['content'],
      userNum: json['userNum'],
      postId: json['postId'],
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
      "postId": postId,
    };
  }
}