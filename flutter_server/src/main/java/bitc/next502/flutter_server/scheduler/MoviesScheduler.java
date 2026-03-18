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
  public void syncNowPlaying() {
    moviesService.updateNowPlayingMovies();
  }

  @Scheduled(cron = "0 10 */6 * * *", zone = "Asia/Seoul")
  public void syncPopular() {
    moviesService.updatePopularMovies();
  }

  @Scheduled(cron = "0 20 */6 * * *", zone = "Asia/Seoul")
  public void syncTopRated() {
    moviesService.updateTopRatedMovies();
  }

//  @PostConstruct
//  public void testImmediateSync() {
//    System.out.println("TMDB 영화 데이터 초기 동기화 시작...");
//    moviesService.updateMoviesOnly(); // movies만 먼저 삽입하는 메서드
//    moviesService.updateAllMovies();  // cast/crew 삽입 포함 전체 동기화
//    System.out.println("TMDB 영화 데이터 동기화 완료!");
//  }
}
