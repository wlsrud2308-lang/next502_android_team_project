package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.UserDTO;
import bitc.next502.flutter_server.service.LoginServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/flutter")
public class LoginController {

  private final LoginServiceImpl loginService;

  @PostMapping("/signup")
  public Object signup(@RequestBody UserDTO user){

    loginService.signupUser(user);

    return user;

  }

}