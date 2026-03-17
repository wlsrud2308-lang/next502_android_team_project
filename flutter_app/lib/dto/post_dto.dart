class PostDto {
  final int postId;
  final String title;
  final String content;
  final String authorName;
  final int viewCnt;
  final int likeCnt;
  final int commentCnt;
  final String createdAt;

  PostDto({
    required this.postId, required this.title, required this.content,
    required this.authorName, required this.viewCnt, required this.likeCnt,
    required this.commentCnt, required this.createdAt,
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
    );
  }
}