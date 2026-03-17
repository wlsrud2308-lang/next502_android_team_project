package bitc.next502.flutter_server.dto;

import lombok.Data;

@Data
public class UserDTO {
  private int userNum;
  private String uid;       // 파이어베이스 UID
  private String email;
  private String nickname;
  private String createDate;
  private String lastLoginTime;
}