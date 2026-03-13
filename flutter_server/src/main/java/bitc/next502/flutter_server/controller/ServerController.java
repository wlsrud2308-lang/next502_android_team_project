package bitc.next502.flutter_server.controller;

import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
public class ServerController {

  @GetMapping("/")
  public String index() {
    return "Flutter App 과 통신하는 Spring boot Server!!";
  }

  //  Flutter 의 Dio 라이브러리와 통신 시 응답 데이터가 반드시 Json 타입이어야 하기 때문에 HashMap 타입 혹은 클래스 객체를 전달해야 함
  @GetMapping("/api/member")
  public Object selectMemberList() {
    Map<String, String> map = new HashMap<>();
    map.put("result", "get 방식으로 접속");
    return map;
  }

  //  Get, Delete 통신 시 클라이언트에서 전달하는 파라미터가 있을 경우 @RequestParam 어노테이션 사용
  @GetMapping("/api/test1")
  public Object test1(@RequestParam("num1") int num1, @RequestParam("num2") int num2) {
    Map<String, Integer> result = new HashMap<>();
    result.put("num1", num1);
    result.put("num2", num2);
    result.put("result", num1 + num2);
    return result;
  }

  @PostMapping("/api/member")
  public Object insertMember() {
    Map<String, String> map =  new HashMap<>();
    map.put("result", "post 방식으로 접속");
    return map;
  }

  //  Post, Put 통신 시 클라이언트에서 전달하는 파라미터가 있을 경우 Json 데이터로 전달받기 때문에 @RequestBody 어노테이션을 사용해야 함
  @PostMapping("/api/test2")
  public Object test2(@RequestBody Map<String, String> map) {
//    Map<String, String> map =  new HashMap<>();
//    map.put("num1", num1);
//    map.put("num2", num2);
    map.put("result", map.get("num1") + map.get("num2"));
//    map.put("result", num1 + num2);

    return map;
  }

}