class PostDto {
  final int postId;
  final String title;
  final String content;
  final String authorName;
  final int viewCnt;
  final int likeCnt;
  final int commentCnt;
  final String createdAt;
  final int userNum;

  PostDto({
    required this.postId,
    required this.title,
    required this.content,
    required this.authorName,
    required this.viewCnt,
    required this.likeCnt,
    required this.commentCnt,
    required this.createdAt,
    required this.userNum
  });

  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      postId: json['postId'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? '익명',
      viewCnt: json['viewCnt'] ?? 0,
      likeCnt: json['likeCnt'] ?? 0,
      commentCnt: json['commentCnt'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      userNum: json['userNum'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'title': title,
      'content': content,
      'authorName': authorName,
      'viewCnt': viewCnt,
      'likeCnt': likeCnt,
      'commentCnt': commentCnt,
      'createdAt': createdAt,
      'userNum': userNum,
    };
  }

  PostDto copyWith({
    String? title,
    String? content,
  }) {
    return PostDto(
      postId: this.postId,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: this.authorName,
      viewCnt: this.viewCnt,
      likeCnt: this.likeCnt,
      commentCnt: this.commentCnt,
      createdAt: this.createdAt,
      userNum: this.userNum,
    );
  }
}