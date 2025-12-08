import 'package:flutter/material.dart';

class ScreenManager {
  // Static variable to store the current screen name
  static String _currentScreen = '';

  // Getter method for current screen
  static String get currentScreen => _currentScreen;

  // Setter method to update the current screen
  static void setCurrentScreen(String screenName) {
    _currentScreen = screenName;
  }

  // Utility method to update current screen based on the screen's type
  static void updateScreenFromType(Widget screen) {
    setCurrentScreen(screen.runtimeType.toString());
  }

  // Reset current screen name to an empty string
  static void reset() {
    _currentScreen = '';
  }
}
