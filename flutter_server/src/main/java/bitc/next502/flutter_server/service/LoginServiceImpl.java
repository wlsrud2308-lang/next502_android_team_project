package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.UserDTO;
import bitc.next502.flutter_server.mapper.LoginMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LoginServiceImpl {

  private final LoginMapper loginMapper;

  public void signupUser(UserDTO user) {
  }
}
