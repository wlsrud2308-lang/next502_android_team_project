import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const String baseUrl = "http://10.0.2.2:8080/movies";

  /// 전체 영화 조회
  static Future<List<Movie>> fetchAllMovies() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception("전체 영화 데이터를 불러오는데 실패");
    }
  }

  /// 홈 화면 영화 조회 (상영중 / 인기 / 평점)
  static Future<List<Movie>> fetchMoviesByCategory(String category) async {
    // category: "nowPlaying", "popular", "topRated"
    final response = await http.get(Uri.parse('$baseUrl/home'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      List<dynamic> movieList = [];
      switch (category) {
        case "nowPlaying":
          movieList = jsonData['nowPlaying'] ?? [];
          break;
        case "popular":
          movieList = jsonData['popular'] ?? [];
          break;
        case "topRated":
          movieList = jsonData['topRated'] ?? [];
          break;
        case "all":
        // 전체 영화 조회
          return fetchAllMovies();
        default:
          movieList = [];
      }

      return movieList.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('영화 데이터를 불러오는데 실패했습니다');
    }
  }
}