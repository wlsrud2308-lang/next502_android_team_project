package bitc.next502.flutter_server.dto;

import lombok.Data;

import java.util.List;

@Data
public class TmdbResponseDTO {

  private List<MoviesDTO> results;
}