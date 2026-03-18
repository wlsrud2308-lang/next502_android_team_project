package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.CastDTO;
import bitc.next502.flutter_server.dto.CrewDTO;
import bitc.next502.flutter_server.dto.MoviesDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MoviesMapper {

  // 영화 저장
  void insertMovie(MoviesDTO movie);

  // 특정 카테고리 영화 삭제
  void deleteCategoryMovies(String category);

  // 전체 영화 조회
  List<MoviesDTO> getAllMovies();

  // 배우 배치 insert
  void insertCastBatch(Long movieId, List<CastDTO> castList);

  // 감독/작업자 배치 insert
  void insertCrewBatch(Long movieId, List<CrewDTO> crewList);
}