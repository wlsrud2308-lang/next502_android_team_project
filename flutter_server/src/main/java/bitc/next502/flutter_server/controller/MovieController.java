package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.MovieDTO;
import bitc.next502.flutter_server.service.MovieService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/flutter")
public class MovieController {

    private final MovieService movieService;


    @PostMapping("/movies")
    public String receiveMovies(@RequestBody List<MovieDTO> movieList) {
        System.out.println("🎉 플러터에서 영화 데이터 도착! 총 " + movieList.size() + "건");

        try {
            movieService.insertMovieList(movieList);
            System.out.println("✅ MySQL DB 저장 완료!");
            return "스프링부트: DB 저장까지 완벽하게 성공했습니다!";
        } catch (Exception e) {
            System.out.println("🚨 DB 저장 실패: " + e.getMessage());
            return "스프링부트: DB 저장 중 오류 발생 - " + e.getMessage();
        }
    }



    @GetMapping("/movies")
    public List<MovieDTO> getMovieList() {
        System.out.println("🎬 DB에서 영화 목록 조회 요청 도착!");
        return movieService.selectMovieList();
    }
}