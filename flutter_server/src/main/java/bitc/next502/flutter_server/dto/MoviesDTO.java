package bitc.next502.flutter_server.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.util.List;

@Data
public class MoviesDTO {

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

  private String category;

  @JsonProperty("vote_average")
  private Double voteAverage;

  @JsonProperty("vote_count")
  private Integer voteCount;

  private Double popularity;

  private List<Integer> genreIds;

  private Boolean adult;

  @JsonProperty("original_language")
  private String originalLanguage;

  private Boolean video;

  private Integer runtime;

  private Long budget;

  private Long revenue;

  private String status;

  private String homepage;
}