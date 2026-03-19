package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.UserDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {
    Integer findUserNumByUid(@Param("uid") String uid);

    void insertUser(UserDTO userDTO);
}