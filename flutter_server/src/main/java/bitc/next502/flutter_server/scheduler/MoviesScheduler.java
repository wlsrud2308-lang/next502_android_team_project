package bitc.next502.flutter_server.scheduler;

import bitc.next502.flutter_server.service.MoviesService;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class MoviesScheduler {

  private final MoviesService moviesService;

  @Scheduled(cron = "0 0 */6 * * *", zone = "Asia/Seoul")
  public void syncMoviesAutomatically() {
    moviesService.updateAllMovies();
    System.out.println("TMDB 영화 데이터 자동 갱신 완료!");
  }

//  @PostConstruct
//  public void testImmediateSync() {
//    System.out.println("테스트용 TMDB 영화 데이터 즉시 갱신 시작...");
//    moviesService.updateAllMovies();
//    System.out.println("테스트용 TMDB 영화 데이터 갱신 완료!");
//  }
}
