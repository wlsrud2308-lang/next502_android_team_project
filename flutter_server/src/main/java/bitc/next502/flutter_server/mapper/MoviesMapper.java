package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.CastDTO;
import bitc.next502.flutter_server.dto.CrewDTO;
import bitc.next502.flutter_server.dto.MoviesDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MoviesMapper {

  // ---------------- 영화 저장 ----------------
  void insertMovie(MoviesDTO movie);

  // ---------------- 영화 조회 ----------------
  List<MoviesDTO> getAllMovies();

  List<MoviesDTO> getNowPlayingMovies();

  List<MoviesDTO> getPopularMovies();

  List<MoviesDTO> getTopRatedMovies();

  // ---------------- 배우/감독 배치 insert ----------------
  void insertCastBatch(Long movieId, List<CastDTO> castList);

  void insertCrewBatch(Long movieId, List<CrewDTO> crewList);

  // ---------------- 플래그 초기화 ----------------
  void resetNowPlaying();

  void resetPopular();

  void resetTopRated();

  // ---------------- 특정 영화 삭제 ----------------
  void deleteMovieById(Long movieId);
}