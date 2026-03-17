package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.MovieDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MovieMapper {
    void insertMovie(MovieDTO movie);
}