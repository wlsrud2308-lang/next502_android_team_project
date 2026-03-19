package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.ReviewDTO;
import java.util.List;

public interface ReviewService {

    List<ReviewDTO> getReviewsByMovie(int movieId);

    ReviewDTO createReview(ReviewDTO reviewDTO);
}
