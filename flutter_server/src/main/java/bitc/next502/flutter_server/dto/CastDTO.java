package bitc.next502.flutter_server.dto;

import lombok.Data;

@Data
public class CastDTO {
  private Long id;            // TMDB person id
  private String name;
  private String characterName;
}