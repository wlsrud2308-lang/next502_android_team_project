class Movie {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double? voteAverage;
  final int? voteCount;
  final double? popularity;
  final String? originalLanguage;
  final int? runtime;

  final int? isNowPlaying;  // 1이면 now playing
  final int? isPopular;     // 1이면 popular
  final int? isTopRated;    // 1이면 top rated

  final List<Cast>? cast;
  final List<Crew>? crew;

  Movie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.originalLanguage,
    this.runtime,
    this.isNowPlaying,
    this.isPopular,
    this.isTopRated,
    this.cast,
    this.crew,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: json['vote_average'] != null ? (json['vote_average'] as num).toDouble() : null,
      voteCount: json['vote_count'] as int?,
      popularity: json['popularity'] != null ? (json['popularity'] as num).toDouble() : null,
      originalLanguage: json['original_language'] as String?,
      runtime: json['runtime'] as int?,
      isNowPlaying: json['is_now_playing'] as int?,
      isPopular: json['is_popular'] as int?,
      isTopRated: json['is_top_rated'] as int?,
      cast: json['cast'] != null
          ? (json['cast'] as List).map((e) => Cast.fromJson(e)).toList()
          : null,
      crew: json['crew'] != null
          ? (json['crew'] as List).map((e) => Crew.fromJson(e)).toList()
          : null,
    );
  }
}

class Cast {
  final int id;
  final String name;
  final String? characterName;
  final String? profilePath;

  Cast({
    required this.id,
    required this.name,
    this.characterName,
    this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      characterName: json['character_name'] ?? json['character'] as String?,
      profilePath: json['profile_path'] as String?,
    );
  }
}

class Crew {
  final int id;
  final String name;
  final String? job;
  final String? profilePath;

  Crew({
    required this.id,
    required this.name,
    this.job,
    this.profilePath,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      job: json['job'] as String?,
      profilePath: json['profile_path'] as String?,
    );
  }
}