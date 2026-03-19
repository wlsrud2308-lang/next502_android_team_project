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
      reviewId: json['reviewId'] ?? json['review_id'] ?? 0,
      userNum: json['userNum'] ?? json['user_num'] ?? 0,
      movieId: json['movieId'] ?? json['movie_id'] ?? 0,
      rating: ((json['rating'] ?? json['ratting']) as num?)?.toDouble() ?? 0.0,
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
      nickname: json['nickname'] ?? '',
    );
  }
}