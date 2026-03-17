package bitc.next502.flutter_server.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor; // 추가
import lombok.AllArgsConstructor;

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
}