package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.MovieDTO;
import bitc.next502.flutter_server.mapper.MovieMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // 추가됨

import java.util.List;

@Service
@RequiredArgsConstructor
public class MovieServiceImpl implements MovieService {

    private final MovieMapper movieMapper;

    // 1. 데이터 저장 (비우고 넣기)
    @Override
    @Transactional
    public void insertMovieList(List<MovieDTO> movieList) {
        //기존에 들어있던 영화 데이터를  비움
        movieMapper.deleteAllMovies();

        // (2) 리스트 영화를  DB 저장
        for (MovieDTO movie : movieList) {
            movieMapper.insertMovie(movie);
        }
    }

    // 2. 데이터 조회 (DB에서 꺼내오기)
    @Override
    public List<MovieDTO> selectMovieList() {

        return movieMapper.selectMovieList();
    }
}