package bitc.next502.flutter_server.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PostDTO {
    private Long postId;
    private String title;
    private String content;
    private String authorName;
    private int viewCnt;
    private int likeCnt;
    private int commentCnt;
    private String createdAt;
    private int userNum;
}