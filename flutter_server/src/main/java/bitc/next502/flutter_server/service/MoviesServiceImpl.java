package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.MoviesDTO;
import bitc.next502.flutter_server.dto.TmdbResponseDTO;
import bitc.next502.flutter_server.mapper.MoviesMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MoviesServiceImpl implements MoviesService {

  private final MoviesMapper moviesMapper;
  private final RestTemplate restTemplate = new RestTemplate();
  private final String apiKey = "70572fb9818902f499a53a287d6055b6"; // TMDB API Key

  @Override
  public List<MoviesDTO> getMovies() {
    return moviesMapper.getAllMovies();
  }

  @Override
  public void updatePopularMovies() {
    List<MoviesDTO> movies = fetchMoviesFromTmdb("popular");
    saveMovies(movies, "popular");
  }

  @Override
  public void updateTopRatedMovies() {
    List<MoviesDTO> movies = fetchMoviesFromTmdb("top_rated");
    saveMovies(movies, "top_rated");
  }

  @Override
  public void updateNowPlayingMovies() {
    List<MoviesDTO> movies = fetchMoviesFromTmdb("now_playing");
    saveMovies(movies, "now_playing");
  }

  @Override
  public void updateAllMovies() {
    updatePopularMovies();
    updateTopRatedMovies();
    updateNowPlayingMovies();
  }

  // =========================
  // TMDB API 호출
  // =========================
  private List<MoviesDTO> fetchMoviesFromTmdb(String category) {
    String url = "https://api.themoviedb.org/3/movie/" + category
        + "?api_key=" + apiKey + "&language=ko-KR&page=1";

    TmdbResponseDTO response = restTemplate.getForObject(url, TmdbResponseDTO.class);
    return response != null ? response.getResults() : List.of();
  }

  // =========================
  // DB 저장
  // =========================
  private void saveMovies(List<MoviesDTO> movies, String category) {
    if (movies == null || movies.isEmpty()) return;

    moviesMapper.deleteCategoryMovies(category); // 기존 카테고리 삭제

    for (MoviesDTO movie : movies) {
      movie.setCategory(category);
      moviesMapper.insertMovie(movie);
    }

    System.out.println(category + " 영화 데이터 저장 완료! 총 " + movies.size() + "개");
  }
}