package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.ReviewDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ReviewMapper {

    List<ReviewDTO> selectByMovieId(int movieId);

    int insertReview(ReviewDTO reviewDTO);
    void updateReview(ReviewDTO reviewDTO);
    void deleteReview(int reviewId);
}