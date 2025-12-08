import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'screen_manager.dart';

class AppNavigation {
  final BuildContext context;

  AppNavigation(this.context);

  /// Push a new screen on top of the current one
  void push(Widget screen) {
    Get.to(() => screen, routeName: screen.runtimeType.toString());
    ScreenManager.updateScreenFromType(screen);
  }

  /// Replace the current screen with a new one
  void pushReplacement(Widget screen) {
    Get.off(() => screen, routeName: screen.runtimeType.toString());
    ScreenManager.updateScreenFromType(screen);
  }

  /// Push a new screen and remove all previous screens
  void pushAndRemoveUntil(Widget screen) {
    Get.offAll(() => screen, routeName: screen.runtimeType.toString());
    ScreenManager.updateScreenFromType(screen);
  }

  /// Push a named route
  void pushNamed(String routeName, {Map<String, String>? params}) {
    Get.toNamed(routeName, parameters: params ?? {});
    ScreenManager.setCurrentScreen(routeName);
  }

  /// Replace with a named route
  void pushReplacementNamed(String routeName, {Map<String, String>? params}) {
    Get.offNamed(routeName, parameters: params ?? {});
    ScreenManager.setCurrentScreen(routeName);
  }

  /// Push a named route and remove all previous screens
  void pushNamedAndRemoveUntil(
    String routeName, {
    Map<String, String>? params,
  }) {
    Get.offAllNamed(routeName, parameters: params ?? {});
    ScreenManager.setCurrentScreen(routeName);
  }

  /// Go back to previous screen
  void pop<T extends Object?>([T? result]) {
    Get.back(result: result);
    _updateCurrentScreenAfterPop();
  }

  /// Check if can pop
  bool canPop() {
    return Get.key.currentState?.canPop() ?? false;
  }

  /// Maybe pop
  Future<bool> maybePop<T extends Object?>([T? result]) async {
    if (canPop()) {
      Get.back(result: result);
      return true;
    }
    return false;
  }

  /// Pop until a specific screen type
  void popUntilScreen(Type screenType) {
    Get.until((route) => route.settings.name == screenType.toString());
    ScreenManager.setCurrentScreen(screenType.toString());
  }

  /// Restart the app
  void restartApp() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  /// Get current screen name
  String getCurrentScreen() {
    return ScreenManager.currentScreen;
  }

  /// Push or replace if screen is same as current
  void pushOrReplaceIfSame(Widget screen) {
    final current = getCurrentScreen();
    final newName = screen.runtimeType.toString();

    if (current == newName) {
      pushReplacement(screen);
    } else {
      push(screen);
    }
  }

  /// Update ScreenManager after pop
  void _updateCurrentScreenAfterPop() {
    final currentRoute = Get.currentRoute;
    ScreenManager.setCurrentScreen(currentRoute);
  }
}
