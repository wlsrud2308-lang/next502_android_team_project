package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.CastDTO;
import bitc.next502.flutter_server.dto.CrewDTO;
import bitc.next502.flutter_server.dto.MoviesDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MoviesMapper {

  void insertMovie(MoviesDTO movie);

  List<MoviesDTO> getAllMovies();

  List<MoviesDTO> getNowPlayingMovies();
  List<MoviesDTO> getPopularMovies();
  List<MoviesDTO> getTopRatedMovies();

  void insertCastBatch(Long movieId, List<CastDTO> castList);
  void insertCrewBatch(Long movieId, List<CrewDTO> crewList);

  void deleteMovieById(Long movieId);
}