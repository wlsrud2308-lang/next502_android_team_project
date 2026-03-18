package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.MoviesDTO;
import java.util.List;

public interface MoviesService {
  List<MoviesDTO> getMovies();              // DB 전체 영화 조회
  List<MoviesDTO> getNowPlayingMovies();    // 최신 영화만 조회
  List<MoviesDTO> getPopularMovies();       // 인기 영화만 조회
  List<MoviesDTO> getTopRatedMovies();      // 평점 영화만 조회
  void updatePopularMovies();               // 인기 영화만 갱신
  void updateTopRatedMovies();              // 평점 영화만 갱신
  void updateNowPlayingMovies();            // 최신 영화만 갱신
  void updateAllMovies();                   // 모든 카테고리 자동 갱신
  void updateMoviesOnly();                  // movies 테이블만 갱신
}