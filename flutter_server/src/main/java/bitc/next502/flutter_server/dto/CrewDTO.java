package bitc.next502.flutter_server.dto;

import lombok.Data;

@Data
public class CrewDTO {
  private Long id;            // TMDB person id
  private String name;
  private String job;         // Director, Writer 등
}