import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // 5개 이상 아이템일 때 필요
      backgroundColor: const Color(0xFF1A1A1A),
      selectedItemColor: Colors.purpleAccent,
      unselectedItemColor: Colors.white38,
      currentIndex: selectedIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.movie), label: '영화정보'),
        BottomNavigationBarItem(icon: Icon(Icons.public), label: '해외영화'),
        BottomNavigationBarItem(icon: Icon(Icons.movie_filter), label: '국내영화'),
        BottomNavigationBarItem(icon: Icon(Icons.forum), label: '자유게시판'),
      ],
    );
  }
}