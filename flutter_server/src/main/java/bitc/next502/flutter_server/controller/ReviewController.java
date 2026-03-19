package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.ReviewDTO;
import bitc.next502.flutter_server.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/reviews")
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    // 영화별 리뷰 조회
    @GetMapping("/{movieId}")
    public List<ReviewDTO> getReviewsByMovie(@PathVariable int movieId) {
        return reviewService.getReviewsByMovie(movieId);
    }

    // 리뷰 작성
    @PostMapping
    public ReviewDTO createReview(@RequestBody ReviewDTO reviewDTO) {
        return reviewService.createReview(reviewDTO);
    }
}