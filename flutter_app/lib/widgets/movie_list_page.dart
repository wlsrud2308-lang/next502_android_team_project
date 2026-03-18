import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../service/movie_service.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  late Future<List<Movie>> movies;

  @override
  void initState() {
    super.initState();
    movies = MovieService.fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("영화 리스트"),
      ),
      body: FutureBuilder<List<Movie>>(
        future: movies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("에러: ${snapshot.error}"));
          }

          final movieList = snapshot.data ?? [];

          if (movieList.isEmpty) {
            return const Center(child: Text("영화 데이터가 없습니다."));
          }

          return ListView.builder(
            itemCount: movieList.length,
            itemBuilder: (context, index) {
              final movie = movieList[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: movie.posterPath != null && movie.posterPath!.isNotEmpty
                      ? Image.network(
                    "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.movie),
                  )
                      : const Icon(Icons.movie, size: 50),
                  title: Text(
                    movie.title ?? "제목 없음",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.overview ?? "줄거리 없음",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (movie.voteAverage != null)
                            Text("⭐ ${movie.voteAverage}"),
                          if (movie.runtime != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text("⏱ ${movie.runtime}분"),
                            ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}