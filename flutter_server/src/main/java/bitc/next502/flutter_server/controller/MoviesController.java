package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.MoviesDTO;
import bitc.next502.flutter_server.service.MoviesService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/movies")
@RequiredArgsConstructor
public class MoviesController {

  private final MoviesService moviesService;

  // 전체 영화 조회
  @GetMapping
  public List<MoviesDTO> movies(){
    return moviesService.getMovies();
  }

  //  상세 조회 추가
  @GetMapping("/{id}")
  public MoviesDTO movieDetail(@PathVariable Long id) {
    return moviesService.getMovieById(id);
  }

  // 홈 화면용: 최신, 인기, 평점 영화
  @GetMapping("/home")
  public Map<String, List<MoviesDTO>> home() {
    return Map.of(
        "nowPlaying", moviesService.getNowPlayingMovies(),
        "popular", moviesService.getPopularMovies(),
        "topRated", moviesService.getTopRatedMovies()
    );
  }
}