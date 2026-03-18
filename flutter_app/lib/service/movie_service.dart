import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const String baseUrl = "http://10.0.2.2:8080/movies";

  static Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception("영화 데이터를 불러오는데 실패");
    }
  }
}