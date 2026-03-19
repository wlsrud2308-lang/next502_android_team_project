package bitc.next502.flutter_server.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ReviewDTO {
    private int reviewId;        // 리뷰 고유 번호
    private int userNum;         // 작성자 번호
    private int movieId;         // 영화 ID
    private double rating;       // 평점
    private String content;      // 리뷰 내용
    private String nickname;     // 작성자 닉네임
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
