import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. 기존 Dio 통신 세팅 유지 (나중에 쓸 수 있도록!)
  final Dio _dio = Dio(
    BaseOptions(
        baseUrl: 'http://10.100.202.5:8080/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        }),
  );

  // 하단 네비게이션 바 선택 인덱스
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // 전체 배경색 살짝 어둡게 (카드 눈에 띄게)
      appBar: AppBar(
        title: const Text(
          'My Community',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // 앱바 글자색
        elevation: 0, // 앱바 그림자 제거
        actions: [
          // 💡 요청하신 우측 상단 로그인 / 회원가입 버튼
          TextButton(
            onPressed: () {
              // TODO: 로그인 화면 이동 로직
              print("로그인 클릭됨");
            },
            child: const Text('로그인', style: TextStyle(color: Colors.indigo)),
          ),
          TextButton(
            onPressed: () {
              // TODO: 회원가입 화면 이동 로직
              print("회원가입 클릭됨");
            },
            child: const Text('회원가입', style: TextStyle(color: Colors.indigo)),
          ),
          const SizedBox(width: 8.0),
        ],
      ),

      // 메인 화면 내용 (스크롤 가능하도록 SingleChildScrollView 사용)
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 인기글 섹션
              _buildSectionTitle('🔥 인기글'),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 160, // 인기글 카드 높이 지정
                // 가로로 스크롤되는 리스트
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3, // 임시로 3개
                  itemBuilder: (context, index) {
                    return _buildPopularCard(index);
                  },
                ),
              ),

              const SizedBox(height: 32.0),

              // ✨ 최신글 섹션
              _buildSectionTitle('✨ 최신글'),
              const SizedBox(height: 12.0),
              // 세로로 나열되는 리스트
              ListView.builder(
                shrinkWrap: true, // ScrollView 안에 ListView 넣을 때 필수 옵션
                physics: const NeverScrollableScrollPhysics(), // 스크롤 충돌 방지
                itemCount: 5, // 임시로 5개
                itemBuilder: (context, index) {
                  return _buildRecentListItem(index);
                },
              ),
            ],
          ),
        ),
      ),

      // 💡 게시판 / 마이페이지 등을 이동할 수 있는 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // TODO: index에 따라 화면 전환 로직 추가 (예: 1번이면 게시판 화면으로)
          });
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: '게시판'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }

  // --- 아래는 UI 디자인을 위한 부분 위젯 분리 함수들 ---

  // 섹션 타이틀 만드는 함수
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    );
  }

  // 인기글 카드 디자인 함수 (가로 스크롤용)
  Widget _buildPopularCard(int index) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4.0, offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '인기글 제목 ${index + 1}\n엄청난 꿀팁입니다!',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.redAccent, size: 16.0),
              const SizedBox(width: 4.0),
              Text('${100 - index * 10}', style: const TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  // 최신글 리스트 아이템 디자인 함수 (세로 리스트용)
  Widget _buildRecentListItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 2.0, offset: const Offset(0, 1))
        ],
      ),
      child: ListTile(
        title: Text('새로 올라온 최신글 제목 ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('안녕하세요, 방금 가입했습니다. 잘 부탁드립니다...', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // TODO: 클릭 시 상세 페이지로 이동
          print("최신글 ${index + 1} 클릭됨");
        },
      ),
    );
  }

// 기존 서버 통신용 함수들은 아래에 그대로 보존 (생략)
// Future<void> onPressedDioGet() async { ... }
// Future<void> onPressedDioGetParam() async { ... }
// Future<void> onPressedDioPost() async { ... }
// Future<void> onPressedDioPostParam() async { ... }
}