package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.MoviesDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MoviesMapper {
  void insertMovie(MoviesDTO movie);
  void deleteCategoryMovies(String category);
  List<MoviesDTO> getAllMovies();
}