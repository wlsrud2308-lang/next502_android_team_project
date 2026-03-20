package bitc.next502.flutter_server.dto;

import com.fasterxml.jackson.annotation.JsonProperty; // 👈 추가
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class PostDTO {
    private Long postId;
    private String boardType;
    private String category;
    private String title;
    private String content;
    private String authorName;
    private Integer viewCnt;
    private Integer likeCnt;
    private Integer commentCnt;
    private String createdAt;
    private int userNum;
}