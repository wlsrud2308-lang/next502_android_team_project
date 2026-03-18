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
  private final String tmdbApiKey = "YOUR_TMDB_API_KEY";

  @Override
  public List<MoviesDTO> getMovies() {
    return moviesMapper.getAllMovies();
  }

  @Override
  public List<MoviesDTO> getNowPlayingMovies() {
    return moviesMapper.getNowPlayingMovies(); // Mapper에서 최신 영화만 조회
  }

  @Override
  public List<MoviesDTO> getPopularMovies() {
    return moviesMapper.getPopularMovies(); // Mapper에서 인기 영화 조회
  }

  @Override
  public List<MoviesDTO> getTopRatedMovies() {
    return moviesMapper.getTopRatedMovies(); // Mapper에서 평점 영화 조회
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
    updateNowPlayingMovies();
    updatePopularMovies();
    updateTopRatedMovies();
  }

  @Override
  public void updateMoviesOnly() {
    List<String> categories = List.of("popular", "top_rated", "now_playing");
    for (String category : categories) {
      List<MoviesDTO> movies = fetchMoviesFromTmdb(category);
      for (MoviesDTO movie : movies) {
        MoviesDTO details = fetchMovieDetail(movie.getId());
        applyTmdbDetails(movie, details);
        moviesMapper.insertMovie(movie);
      }
    }
    System.out.println("모든 영화 movies 테이블 동기화 완료!");
  }

  // ===== TMDb + DB 통합 =====
  private void updateCategoryMovies(String category) {
    List<MoviesDTO> movies = fetchMoviesFromTmdb(category);
    if (movies == null || movies.isEmpty()) return;

    for (MoviesDTO movie : movies) {
      MoviesDTO details = fetchMovieDetail(movie.getId());
      applyTmdbDetails(movie, details);

      moviesMapper.insertMovie(movie);

      CreditsDTO credits = fetchCredits(movie.getId());
      List<CastDTO> topCast = credits.getCast() != null
          ? credits.getCast().stream().limit(10).toList()
          : List.of();
      saveCast(movie.getId(), topCast);

      List<CrewDTO> directors = credits.getCrew() != null
          ? credits.getCrew().stream().filter(c -> "Director".equals(c.getJob())).toList()
          : List.of();
      saveCrew(movie.getId(), directors);
    }

    System.out.println(category + " 영화 데이터 + cast/crew 저장 완료! 총 " + movies.size() + "개");
  }

  private void applyTmdbDetails(MoviesDTO target, MoviesDTO details) {
    if (details == null) return;
    target.setRuntime(details.getRuntime());
    target.setOverview(details.getOverview());
    target.setPosterPath(details.getPosterPath());
    target.setBackdropPath(details.getBackdropPath());
    target.setVoteAverage(details.getVoteAverage());
    target.setVoteCount(details.getVoteCount());
    target.setPopularity(details.getPopularity());
    target.setReleaseDate(details.getReleaseDate());
  }

  private List<MoviesDTO> fetchMoviesFromTmdb(String category) {
    String url = "https://api.themoviedb.org/3/movie/" + category
        + "?api_key=" + tmdbApiKey + "&language=ko-KR&page=1";
    try {
      TmdbResponseDTO response = restTemplate.getForObject(url, TmdbResponseDTO.class);
      return response != null ? response.getResults() : List.of();
    } catch (Exception e) {
      System.out.println(category + " 영화 가져오기 실패: " + e.getMessage());
      return List.of();
    }
  }

  private MoviesDTO fetchMovieDetail(Long movieId) {
    String url = "https://api.themoviedb.org/3/movie/" + movieId
        + "?api_key=" + tmdbApiKey + "&language=ko-KR";
    try {
      return restTemplate.getForObject(url, MoviesDTO.class);
    } catch (Exception e) {
      System.out.println("상세 정보 가져오기 실패: " + movieId);
      return null;
    }
  }

  private CreditsDTO fetchCredits(Long movieId) {
    String url = "https://api.themoviedb.org/3/movie/" + movieId
        + "/credits?api_key=" + tmdbApiKey + "&language=ko-KR";
    try {
      return restTemplate.getForObject(url, CreditsDTO.class);
    } catch (Exception e) {
      System.out.println("Credits 가져오기 실패: " + movieId);
      return new CreditsDTO();
    }
  }

  private void saveCast(Long movieId, List<CastDTO> castList) {
    if (castList == null || castList.isEmpty()) return;
    try {
      moviesMapper.insertCastBatch(movieId, castList);
    } catch (Exception e) {
      System.out.println("Cast 저장 실패: " + movieId + " / " + e.getMessage());
    }
  }

  private void saveCrew(Long movieId, List<CrewDTO> crewList) {
    if (crewList == null || crewList.isEmpty()) return;
    try {
      moviesMapper.insertCrewBatch(movieId, crewList);
    } catch (Exception e) {
      System.out.println("Crew 저장 실패: " + movieId + " / " + e.getMessage());
    }
  }
}