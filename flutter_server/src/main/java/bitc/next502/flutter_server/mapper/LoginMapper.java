package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.UserDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface LoginMapper {

  void insertUser(UserDTO user);

}



