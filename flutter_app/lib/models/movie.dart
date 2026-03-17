class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;   // null 가능
  final String? backdropPath; // 상세 화면용
  final String? category;
  final double? voteAverage;
  final int? runtime;         // 서버에서 null 가능
  final String? homepage;     // 서버에서 null 가능

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.category,
    this.voteAverage,
    this.runtime,
    this.homepage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],    // TMDB JSON key와 맞춤
      backdropPath: json['backdrop_path'],
      category: json['category'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      runtime: json['runtime'],
      homepage: json['homepage'],
    );
  }
}