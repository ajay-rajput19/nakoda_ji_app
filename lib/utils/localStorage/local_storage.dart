import 'package:shared_preferences/shared_preferences.dart';

enum AllAppsEnum {
  user,
  member
}

class FollowKeys {
 
  static const String user = "user";
  static const String member = "member";


  /// Converts a string to the corresponding AllAppsEnum.
  static AllAppsEnum getUserTypeInAllAppEnum(String givenUserType) {
    switch (givenUserType) {
      case member:
        return AllAppsEnum.member;
    
      default:
        return AllAppsEnum.user;
    }
  }

  /// Converts an AllAppsEnum to its corresponding string key.
  static String getKeygetUserTypeInString(AllAppsEnum userEnum) {
    switch (userEnum) {
      case AllAppsEnum.member:
        return member;
    
      case AllAppsEnum.user:
        return user;
    }
  }

  /// Returns all follow keys as list
  static List<String> get allKeys => [
    user,
   member
  ];
}

class LocalStorage {

  static const String userAuthToken = 'userAuthToken';

  static const String memberAuthToken = 'memberAuthToken';

  static const String userRole = 'userRole';
  
  // Member registration step persistence
  static const String memberRegistrationStep = 'memberRegistrationStep';
  static const String memberRegistrationApplicationId = 'memberRegistrationApplicationId';
  static const String memberRegistrationSelectedOption = 'memberRegistrationSelectedOption';


  // Initialize SharedPreferences safely and asynchronously
}

class SharedPrefString {
  static SharedPreferences? _prefs;

  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }


  static Future<void> setPrefs(String givenKey, String givenValue) async {
    await _initPrefs();
    _prefs?.setString(givenKey, givenValue);
  }

  static Future<String> getPrefs(String givenKey) async {
    await _initPrefs();
    return _prefs?.getString(givenKey) ?? 'null';
  }

  static Future<void> removePrefs(String givenKey) async {
    await _initPrefs();
    _prefs?.remove(givenKey);
  }
  
  // Integer preference helpers
  static Future<void> setIntPrefs(String givenKey, int givenValue) async {
    await _initPrefs();
    _prefs?.setInt(givenKey, givenValue);
  }
  
  static Future<int> getIntPrefs(String givenKey) async {
    await _initPrefs();
    return _prefs?.getInt(givenKey) ?? 0;
  }
  
  // Remove integer preference
  static Future<void> removeIntPrefs(String givenKey) async {
    await _initPrefs();
    _prefs?.remove(givenKey);
  }
}