package bitc.next502.flutter_server.scheduler;

import bitc.next502.flutter_server.service.MoviesService;
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
}