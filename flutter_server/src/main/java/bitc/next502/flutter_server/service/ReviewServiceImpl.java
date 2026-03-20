package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.ReviewDTO;
import bitc.next502.flutter_server.mapper.ReviewMapper;
import bitc.next502.flutter_server.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ReviewServiceImpl implements ReviewService {

    @Autowired
    private ReviewMapper reviewMapper;

    @Override
    public List<ReviewDTO> getReviewsByMovie(int movieId) {
        return reviewMapper.selectByMovieId(movieId);
    }

    @Override
    public ReviewDTO createReview(ReviewDTO reviewDTO) {
        reviewDTO.setCreatedAt(LocalDateTime.now());
        reviewDTO.setUpdatedAt(LocalDateTime.now());
        reviewMapper.insertReview(reviewDTO);
        return reviewDTO;
    }

    @Override
    public void updateReview(ReviewDTO reviewDTO) {
        reviewMapper.updateReview(reviewDTO);
    }

    @Override
    public void deleteReview(int reviewId) {
        reviewMapper.deleteReview(reviewId);
    }
}