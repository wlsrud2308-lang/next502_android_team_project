package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.CastDTO;
import bitc.next502.flutter_server.dto.CreditsDTO;
import bitc.next502.flutter_server.dto.CrewDTO;
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
    updateCategoryMovies("popular");
  }

  @Override
  public void updateTopRatedMovies() {
    updateCategoryMovies("top_rated");
  }

  @Override
  public void updateNowPlayingMovies() {
    updateCategoryMovies("now_playing");
  }

  @Override
  public void updateAllMovies() {
    updatePopularMovies();
    updateTopRatedMovies();
    updateNowPlayingMovies();
  }

  // =========================
  // 카테고리별 영화 업데이트 (리스트 + 상세 정보 + 배우/감독)
  // =========================
  private void updateCategoryMovies(String category) {
    List<MoviesDTO> movies = fetchMoviesFromTmdb(category);

    for (MoviesDTO movie : movies) {
      // 상세 정보 가져오기
      MoviesDTO details = fetchMovieDetail(movie.getId());
      if (details != null) {
        movie.setRuntime(details.getRuntime());
        movie.setBudget(details.getBudget());
        movie.setRevenue(details.getRevenue());
        movie.setHomepage(details.getHomepage());
        movie.setStatus(details.getStatus());
        movie.setOriginalLanguage(details.getOriginalLanguage());
        movie.setAdult(details.getAdult());
        movie.setVideo(details.getVideo());
      }

      // Credits 가져오기 (배우/감독)
      CreditsDTO credits = fetchCredits(movie.getId());

      // 배우 상위 10명
      List<CastDTO> topCast = credits.getCast().stream()
          .limit(10)
          .toList();
      movie.setCast(topCast);
      saveCast(movie.getId(), topCast);

      // 감독만
      List<CrewDTO> directors = credits.getCrew().stream()
          .filter(c -> "Director".equals(c.getJob()))
          .toList();
      movie.setCrew(directors);
      saveCrew(movie.getId(), directors);
    }

    saveMovies(movies, category);
  }

  // =========================
  // TMDB 리스트 API 호출
  // =========================
  private List<MoviesDTO> fetchMoviesFromTmdb(String category) {
    String url = "https://api.themoviedb.org/3/movie/" + category
        + "?api_key=" + apiKey + "&language=ko-KR&page=1";

    TmdbResponseDTO response = restTemplate.getForObject(url, TmdbResponseDTO.class);
    return response != null ? response.getResults() : List.of();
  }

  // =========================
  // TMDB 상세 정보 API 호출
  // =========================
  private MoviesDTO fetchMovieDetail(Long movieId) {
    String url = "https://api.themoviedb.org/3/movie/" + movieId
        + "?api_key=" + apiKey + "&language=ko-KR";

    try {
      return restTemplate.getForObject(url, MoviesDTO.class);
    } catch (Exception e) {
      System.out.println("상세 정보 가져오기 실패: " + movieId);
      return null;
    }
  }

  // =========================
  // TMDB Credits API 호출
  // =========================
  private CreditsDTO fetchCredits(Long movieId) {
    String url = "https://api.themoviedb.org/3/movie/" + movieId
        + "/credits?api_key=" + apiKey + "&language=ko-KR";

    try {
      return restTemplate.getForObject(url, CreditsDTO.class);
    } catch (Exception e) {
      System.out.println("Credits 가져오기 실패: " + movieId);
      return new CreditsDTO(); // 빈 객체 반환
    }
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

  private void saveCast(Long movieId, List<CastDTO> castList) {
    if (castList == null || castList.isEmpty()) return;
    moviesMapper.insertCastBatch(movieId, castList);
  }

  private void saveCrew(Long movieId, List<CrewDTO> crewList) {
    if (crewList == null || crewList.isEmpty()) return;
    moviesMapper.insertCrewBatch(movieId, crewList);
  }
}