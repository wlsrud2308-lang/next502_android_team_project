class Review {
  final int reviewId;
  final int userNum;
  final int movieId;
  final double rating; // 평점
  final String content;
  final String createdAt;

  Review({
    required this.reviewId,
    required this.userNum,
    required this.movieId,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'],
      userNum: json['user_num'],
      movieId: json['movie_id'],
      rating: (json['ratting'] as num).toDouble(),
      content: json['content'],
      createdAt: json['created_at'],
    );
  }
}