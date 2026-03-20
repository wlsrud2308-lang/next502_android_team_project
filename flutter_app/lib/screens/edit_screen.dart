import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/screens/home_screen.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _withdrawalReasonController = TextEditingController();

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _withdrawalReasonController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final dio = Dio();
      final response = await dio.get('http://10.0.2.2:8080/flutter/user/${currentUser!.uid}');
      if (response.statusCode == 200) {
        setState(() {
          userData = response.data;
          isLoading = false;
        });
      }
    } catch (e) {
      print("유저 정보 로드 실패: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _handlePasswordChange() async {
    final String currentPw = _currentPasswordController.text.trim();
    final String newPw = _newPasswordController.text.trim();

    if (currentPw.isEmpty || newPw.isEmpty) {
      _showSnackBar("모든 칸을 입력해주세요.");
      return;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPw,
      );
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPw);

      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar("비밀번호가 성공적으로 변경되었습니다.");
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showSnackBar("현재 비밀번호가 일치하지 않습니다.");
      } else if (e.code == 'weak-password') {
        _showSnackBar("새 비밀번호는 6자리 이상이어야 합니다.");
      } else {
        _showSnackBar("오류: ${e.message}");
      }
    } catch (e) {
      _showSnackBar("알 수 없는 오류가 발생했습니다.");
    }
  }

  Future<void> _handleWithdrawal() async {
    final String reason = _withdrawalReasonController.text.trim();
    if (reason.isEmpty) {
      _showSnackBar("탈퇴 사유를 입력해주세요.");
      return;
    }

    try {
      setState(() => isLoading = true);

      final dio = Dio();
      final response = await dio.post(
        'http://10.0.2.2:8080/flutter/withdraw',
        data: {
          "uid": currentUser!.uid,
          "email": currentUser!.email,
          "reason": reason,
        },
      );

      if (response.statusCode == 200) {
        await currentUser!.delete();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MovieHomeScreen()),
              (route) => false,
        );
        _showSnackBar("그동안 이용해주셔서 감사합니다.");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showSnackBar("보안을 위해 다시 로그인한 뒤 탈퇴를 진행해주세요.");
      } else {
        _showSnackBar("탈퇴 실패: ${e.message}");
      }
    } catch (e) {
      _showSnackBar("서버 통신 중 오류가 발생했습니다.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("비밀번호 변경", style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.black87),
              decoration: _dialogInputDecoration("현재 비밀번호"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.black87),
              decoration: _dialogInputDecoration("새 비밀번호"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소", style: TextStyle(color: Colors.black54))),
          TextButton(
            onPressed: _handlePasswordChange,
            child: const Text("변경하기", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showWithdrawalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("서비스 탈퇴", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("정말 탈퇴하시겠습니까?\n탈퇴 사유를 남겨주시면 큰 도움이 됩니다.",
                style: TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 15),
            TextField(
              controller: _withdrawalReasonController,
              maxLines: 3,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "사유를 입력해주세요 (필수)",
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소", style: TextStyle(color: Colors.black54))),
          ElevatedButton(
            onPressed: _handleWithdrawal,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("탈퇴하기", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
      );
    }

    final String displayEmail = currentUser?.email ?? "이메일 정보 없음";
    final String displayNickname = userData?['nickname'] ?? "정보 없음";
    final String displayName = userData?['userName'] ?? "정보 없음";
    final String displayTel = userData?['userTel']?.toString() ?? "정보 없음";
    final String displayBirth = userData?['userBirth'] ?? "정보 없음";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // 앱바도 흰색
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("개인정보 관리",
            style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // 상태바 아이콘 검정색
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSectionTitle("로그인 정보"),
            _buildInfoTile("이메일 계정", displayEmail, isEditable: false),
            GestureDetector(
              onTap: _showPasswordChangeDialog,
              child: _buildInfoTile("비밀번호 변경", "보안을 위해 주기적으로 변경하세요", isEditable: true),
            ),
            _buildInfoTile("닉네임", displayNickname, isEditable: true),
            const SizedBox(height: 30),
            _buildSectionTitle("개인정보"),
            _buildInfoTile("이름 / 실명", displayName, isEditable: true),
            _buildInfoTile("휴대폰 번호", displayTel, isEditable: true),
            _buildInfoTile("생년월일", displayBirth, isEditable: false),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MovieHomeScreen()),
                            (route) => false,
                      );
                    },
                    child: const Text("로그아웃", style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                  ),
                  TextButton(
                    onPressed: _showWithdrawalDialog,
                    child: const Text("서비스 탈퇴하기",
                        style: TextStyle(color: Colors.black54, fontSize: 12, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.purple, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {required bool isEditable}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
          if (isEditable)
            const Icon(Icons.chevron_right, color: Colors.black38, size: 20)
          else
            const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
        ],
      ),
    );
  }
}