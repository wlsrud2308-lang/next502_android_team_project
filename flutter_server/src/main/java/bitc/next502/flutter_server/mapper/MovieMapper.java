package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.MovieDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface MovieMapper {
    void insertMovie(MovieDTO movie);
    void deleteAllMovies();

    List<MovieDTO> selectMovieList();
}