package bitc.next502.flutter_server.dto;

import lombok.Data;

@Data
public class UserDTO {
  private int userNum;
  private String uid;
  private String email;
  private String nickname;


  private String userName;
  private String userTel;
  private String userBirth;

  private String createDate;
  private String lastLoginTime;
}