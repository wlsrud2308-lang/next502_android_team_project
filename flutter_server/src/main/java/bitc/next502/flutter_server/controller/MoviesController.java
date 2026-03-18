package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.MoviesDTO;
import bitc.next502.flutter_server.service.MoviesService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/movies")
@RequiredArgsConstructor
public class MoviesController {

  private final MoviesService moviesService;

  @GetMapping("/home")
  public Map<String, List<MoviesDTO>> home() {
    return Map.of(
        "nowPlaying", moviesService.getNowPlayingMovies(),
        "popular", moviesService.getPopularMovies(),
        "topRated", moviesService.getTopRatedMovies()
    );
  }

  @GetMapping
  public List<MoviesDTO> movies(){
    return moviesService.getMovies();
  }

}