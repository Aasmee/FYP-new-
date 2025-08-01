import 'package:flutter/material.dart';
import 'package:frontend/screens/Home/home.dart';
import 'package:frontend/screens/Pantry/pantry.dart';
import 'package:frontend/screens/Posts/post.dart';
import 'package:frontend/screens/Profile/profile.dart';
import 'package:frontend/screens/Recipe/recipe_list.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  NavBarState createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Home(),
    RecipeListScreen(),
    CreatePostScreen(),
    Pantry(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: Color(0xFFAF7036),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFAF7036),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          items: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.menu_book, "Recipe", 1),
            _buildNavItem(Icons.add_box_outlined, "Add", 2),
            _buildNavItem(Icons.storefront, "Pantry", 3),
            _buildNavItem(Icons.person, "Profile", 4),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _currentIndex == index ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color:
              _currentIndex == index ? const Color(0xFFAF7036) : Colors.white,
        ),
      ),
      label: label,
    );
  }
}
