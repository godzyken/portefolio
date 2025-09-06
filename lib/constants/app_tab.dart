import 'package:flutter/material.dart';

enum AppTab {
  home(path: '/', label: 'Home', icon: Icons.home),
  experiences(path: '/experiences', label: 'Exp', icon: Icons.history),
  projects(path: '/projects', label: 'Projets', icon: Icons.work),
  contact(path: '/contact', label: 'Contact', icon: Icons.mail);

  final String path;
  final String label;
  final IconData icon;

  const AppTab({required this.path, required this.label, required this.icon});

  BottomNavigationBarItem get navItem =>
      BottomNavigationBarItem(icon: Icon(icon), label: label);

  static AppTab fromLocation(String location) {
    if (location.startsWith('/experiences')) return AppTab.experiences;
    if (location.startsWith('/projects')) return AppTab.projects;
    if (location.startsWith('/contact')) return AppTab.contact;
    return AppTab.home;
  }
}
