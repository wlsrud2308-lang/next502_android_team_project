package bitc.next502.flutter_server.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class CastDTO {
  private Long id;            // TMDB person id
  private String name;
  @JsonProperty("character")
  private String characterName; // TMDB character 필드를 characterName으로 매핑

  @JsonProperty("profile_path")
  private String profilePath;   // 프로필 이미지 경로
}