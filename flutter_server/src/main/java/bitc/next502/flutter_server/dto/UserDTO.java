package bitc.next502.flutter_server.dto;

import lombok.Data;

@Data
public class UserDTO {

  private String email;
  private String password;
  private String id;
  private String nickname;
}
