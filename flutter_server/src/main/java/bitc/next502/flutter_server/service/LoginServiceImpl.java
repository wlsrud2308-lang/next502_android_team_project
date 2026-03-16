package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.UserDTO;
import bitc.next502.flutter_server.mapper.LoginMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LoginServiceImpl implements LoginService {

  private final LoginMapper loginMapper;

  @Override
  public void signupUser(UserDTO user) {

    loginMapper.insertUser(user);

  }
}