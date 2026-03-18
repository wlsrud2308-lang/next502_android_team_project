package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.MoviesDTO;
import java.util.List;

public interface MoviesService {

  // DB 조회
  List<MoviesDTO> getMovies();
  List<MoviesDTO> getNowPlayingMovies();
  List<MoviesDTO> getPopularMovies();
  List<MoviesDTO> getTopRatedMovies();

  // 데이터 갱신
  void updateNowPlayingMovies();
  void updatePopularMovies();
  void updateTopRatedMovies();
  void updateAllMovies();
  void updateMoviesOnly();
}