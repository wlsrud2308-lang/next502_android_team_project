package bitc.next502.flutter_server;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("bitc.next502.flutter_server.mapper") // 여기에 Mapper 패키지 경로 적기
public class FlutterServerApplication {
  public static void main(String[] args) {
    SpringApplication.run(FlutterServerApplication.class, args);
  }
}