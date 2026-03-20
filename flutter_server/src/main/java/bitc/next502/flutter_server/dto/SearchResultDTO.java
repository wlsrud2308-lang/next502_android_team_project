package bitc.next502.flutter_server.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class SearchResultDTO {
  private List<MoviesDTO> movies;
  private List<PostDTO> posts;
}