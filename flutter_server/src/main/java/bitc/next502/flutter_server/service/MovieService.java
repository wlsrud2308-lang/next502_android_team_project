package bitc.next502.flutter_server.service;
import bitc.next502.flutter_server.dto.MovieDTO;
import java.util.List;
public interface MovieService {
    void insertMovieList(List<MovieDTO> movieDTOList);
}
