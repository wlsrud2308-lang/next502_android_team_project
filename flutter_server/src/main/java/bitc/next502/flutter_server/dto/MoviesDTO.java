package bitc.next502.flutter_server.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

@Data
public class MoviesDTO {

  // ===== TMDb 기본 =====
  private Long id;
  private String title;

  @JsonProperty("original_title")
  private String originalTitle;

  private String overview;

  @JsonProperty("poster_path")
  private String posterPath;

  @JsonProperty("backdrop_path")
  private String backdropPath;

  @JsonProperty("release_date")
  private String releaseDate;

  @JsonProperty("vote_average")
  private Double voteAverage;

  @JsonProperty("vote_count")
  private Integer voteCount;

  private Double popularity;

  @JsonProperty("genre_ids")
  private List<Integer> genreIds;

  @JsonProperty("original_language")
  private String originalLanguage;

  private Integer runtime;

  // ===== TMDb 상세 =====
  private List<CastDTO> cast;   // 배우
  private List<CrewDTO> crew;   // 감독 (TMDb만 사용)

}
