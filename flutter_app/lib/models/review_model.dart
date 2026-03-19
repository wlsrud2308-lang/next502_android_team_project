class Review {
  final int reviewId;
  final int userNum;
  final int movieId;
  final double rating;
  final String content;
  final String createdAt;
  final String nickname;

  Review({
    required this.reviewId,
    required this.userNum,
    required this.movieId,
    required this.rating,
    required this.content,
    required this.createdAt,
    required this.nickname,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: (json['reviewId'] ?? json['review_id'] ?? 0) as int,
      userNum: (json['userNum'] ?? json['user_num'] ?? 0) as int,
      movieId: (json['movieId'] ?? json['movie_id'] ?? 0) as int,
      rating: ((json['rating'] ?? json['ratting'] ?? 0) as num).toDouble(),
      content: (json['content'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? json['created_at'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
    );
  }
}