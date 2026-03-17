package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.MovieDTO;
import bitc.next502.flutter_server.mapper.MovieMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MovieServiceImpl implements MovieService {

    private final MovieMapper movieMapper;

    @Override
    public void insertMovieList(List<MovieDTO> movieList) {
        // 리스트에 담긴 10개의 영화를 하나씩 꺼내서 DB 저장 쿼리 실행
        for (MovieDTO movie : movieList) {
            movieMapper.insertMovie(movie);
        }
    }
}