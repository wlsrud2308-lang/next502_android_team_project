package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.UserDTO;

import java.util.List;

public interface LoginService {

  public void signupUser(UserDTO user);

  UserDTO getUserByUid(String uid);
}
