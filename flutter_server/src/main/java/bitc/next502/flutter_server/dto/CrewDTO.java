package bitc.next502.flutter_server.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class CrewDTO {
  private Long id;            // TMDB person id
  private String name;
  @JsonProperty("job")
  private String job;

  @JsonProperty("profile_path")
  private String profilePath;      // Director, Writer 등
}