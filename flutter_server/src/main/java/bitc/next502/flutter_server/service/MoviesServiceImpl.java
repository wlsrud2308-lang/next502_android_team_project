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

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MoviesServiceImpl implements MoviesService {

  private final MoviesMapper moviesMapper;
  private final RestTemplate restTemplate = new RestTemplate();
  private final String tmdbApiKey = "70572fb9818902f499a53a287d6055b6";
  private final String kobisApiKey = "4560a7f48271cc85ea785b96d415149b";

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

  @Override
  public void updateMoviesOnly() {
    List<String> categories = List.of("popular", "top_rated", "now_playing");
    for (String category : categories) {
      List<MoviesDTO> movies = fetchMoviesFromTmdb(category);
      for (MoviesDTO movie : movies) {
        MoviesDTO details = fetchMovieDetail(movie.getId());
        applyTmdbDetails(movie, details);
        integrateKobisData(movie);          // KOBIS 통합
        moviesMapper.insertMovie(movie);    // category 없이 저장
      }
    }
    System.out.println("모든 영화 movies 테이블 동기화 완료!");
  }

  // ================= TMDb + KOBIS 통합 =================
  private void updateCategoryMovies(String category) {
    List<MoviesDTO> movies = fetchMoviesFromTmdb(category);
    if (movies == null || movies.isEmpty()) return;

    for (MoviesDTO movie : movies) {
      MoviesDTO details = fetchMovieDetail(movie.getId());
      applyTmdbDetails(movie, details);

      integrateKobisData(movie);

      // DB 저장
      moviesMapper.insertMovie(movie);

      // Credits 저장
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

  // ================= TMDb 상세 정보 적용 =================
  private void applyTmdbDetails(MoviesDTO target, MoviesDTO details) {
    if (details == null) return;
    target.setRuntime(details.getRuntime());
    target.setOverview(details.getOverview());
    target.setPosterPath(details.getPosterPath());
    target.setBackdropPath(details.getBackdropPath());
    target.setVoteAverage(details.getVoteAverage());
    target.setVoteCount(details.getVoteCount());
    target.setPopularity(details.getPopularity());
  }

  // ================= KOBIS 데이터 통합 =================
  private void integrateKobisData(MoviesDTO movie) {
    try {
      MoviesDTO kobis = fetchKobisMovie(movie.getTitle());
      if (kobis != null) {
        movie.setMovieCd(kobis.getMovieCd());
        movie.setAudienceCount(kobis.getAudienceCount());
        if (movie.getReleaseDate() == null && kobis.getReleaseDate() != null) {
          movie.setReleaseDate(kobis.getReleaseDate());
        }
      }
    } catch (Exception e) {
      System.out.println("KOBIS 데이터 통합 실패: " + movie.getTitle());
    }
  }

  private MoviesDTO fetchKobisMovie(String title) {
    try {
      String url = "http://www.kobis.or.kr/kobisopenapi/webservice/rest/movie/searchMovieList.json"
          + "?key=" + kobisApiKey
          + "&movieNm=" + URLEncoder.encode(title, StandardCharsets.UTF_8);

      Map<String, Object> response = restTemplate.getForObject(url, Map.class);
      Map<String, Object> result = (Map<String, Object>) response.get("movieListResult");
      List<Map<String, Object>> movieList = (List<Map<String, Object>>) result.get("movieList");

      if (movieList != null && !movieList.isEmpty()) {
        Map<String, Object> first = movieList.get(0);
        MoviesDTO dto = new MoviesDTO();
        dto.setMovieCd((String) first.get("movieCd"));

        // 관객수 조회 (별도 API)
        String infoUrl = "http://www.kobis.or.kr/kobisopenapi/webservice/rest/movie/searchMovieInfo.json"
            + "?key=" + kobisApiKey
            + "&movieCd=" + dto.getMovieCd();

        Map<String, Object> infoResponse = restTemplate.getForObject(infoUrl, Map.class);
        Map<String, Object> infoResult = (Map<String, Object>) infoResponse.get("movieInfoResult");
        Map<String, Object> movieInfo = (Map<String, Object>) infoResult.get("movieInfo");

        if (movieInfo.get("audiAcc") != null) {
          dto.setAudienceCount(Long.parseLong((String) movieInfo.get("audiAcc")));
        }

        return dto;
      }
    } catch (Exception e) {
      System.out.println("KOBIS API 호출 실패: " + title + " / " + e.getMessage());
    }
    return null;
  }

  // ================= TMDb API 호출 =================
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

  // ================= DB 저장: cast/crew =================
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