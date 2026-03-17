package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.MovieDTO;
import bitc.next502.flutter_server.service.MovieService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequiredArgsConstructor // 💡 의존성 주입을 위해 필수!
@RequestMapping("/flutter")
public class MovieController {

    private final MovieService movieService; // 💡 서비스 연결

    @PostMapping("/movies")
    public String receiveMovies(@RequestBody List<MovieDTO> movieList) {
        System.out.println("🎉 플러터에서 영화 데이터 도착! 총 " + movieList.size() + "건");

        try {
            // DB 저장 로직 실행
            movieService.insertMovieList(movieList);
            System.out.println("✅ MySQL DB 저장 완료!");
            return "스프링부트: DB 저장까지 완벽하게 성공했습니다!";
        } catch (Exception e) {
            System.out.println("🚨 DB 저장 실패: " + e.getMessage());
            return "스프링부트: DB 저장 중 오류 발생";
        }
    }
}