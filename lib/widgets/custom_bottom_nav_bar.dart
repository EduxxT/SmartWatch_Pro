import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: kDarkSecondaryBackground,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kAccentColor,
      unselectedItemColor: kDarkSecondaryText,
      selectedLabelStyle: textStyle.copyWith(fontSize: 12, color: kAccentColor),
      unselectedLabelStyle: textStyle.copyWith(fontSize: 12, color: kDarkSecondaryText),
      
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mode_night_rounded),
          label: 'Sleep',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.run_circle_outlined),
          label: 'Activity',
        ),
      ],
      elevation: 0,
    );
  }
}
