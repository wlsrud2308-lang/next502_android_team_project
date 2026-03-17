package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.MovieDTO;
import java.util.List;

public interface MovieService {
    // 1. 영화 리스트 저장 (기존에 있던 것)
    void insertMovieList(List<MovieDTO> movieList);

    // 2. 영화 리스트 조회 (여기에 이 줄을 추가해야 빨간 줄이 사라집니다!)
    List<MovieDTO> selectMovieList();
}