package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.CastDTO;
import bitc.next502.flutter_server.dto.CrewDTO;
import bitc.next502.flutter_server.dto.MoviesDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MoviesMapper {

  // 영화 저장
  void insertMovie(MoviesDTO movie);   // category 필드 없이 MoviesDTO만 전달

  // 전체 영화 조회
  List<MoviesDTO> getAllMovies();

  // 배우 배치 insert
  void insertCastBatch(Long movieId, List<CastDTO> castList);

  // 감독/작업자 배치 insert
  void insertCrewBatch(Long movieId, List<CrewDTO> crewList);

  // 특정 영화 삭제 (category 대신 movieId 기준)
  void deleteMovieById(Long movieId);
}