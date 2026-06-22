import 'package:flutter/material.dart';

/// Provides theme mode state management via InheritedWidget.
class ThemeProvider extends StatefulWidget {
  final Widget child;

  const ThemeProvider({super.key, required this.child});

  static ThemeProviderState of(BuildContext context) {
    return context.findAncestorStateOfType<ThemeProviderState>()!;
  }

  @override
  State<ThemeProvider> createState() => ThemeProviderState();
}

class ThemeProviderState extends State<ThemeProvider> {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark to match mockup

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
