import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_choose_form.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_register_page.dart';
import 'package:nakoda_ji/apps/member/screens/dashboard/member_dashboard.dart';
import 'package:nakoda_ji/apps/user/screens/auth/user_Signup.dart';
import 'package:nakoda_ji/utils/localStorage/local_storage.dart';
import 'package:nakoda_ji/utils/syncfusion_license.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register Syncfusion license
  SyncfusionLicense.register();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString(LocalStorage.userAuthToken);
  String? role = prefs.getString(LocalStorage.userRole);

  Widget initialWidget = SignUpPage();

  if (token != null && token.isNotEmpty) {
    if (role != null && role.toLowerCase() == 'member') {
      initialWidget = const MemberDashboard();
    } else {
      // Check if there's a saved registration step
      int savedStep = prefs.getInt(LocalStorage.memberRegistrationStep) ?? 0;
      int selectedOption = prefs.getInt(LocalStorage.memberRegistrationSelectedOption) ?? 0;
      
      if (savedStep > 0) {
        // User was in the middle of registration, continue from where they left off
        initialWidget = const MemberRegisterPage();
      } else if (selectedOption > 0) {
        // User selected an option but didn't start registration
        initialWidget = const MemberChooseForm();
      } else {
        initialWidget = const MemberChooseForm();
      }
    }
  }

  runApp(ProviderScope(child: AppRoot(initialWidget: initialWidget)));
}

class AppRoot extends StatelessWidget {
  final Widget? initialWidget;
  const AppRoot({super.key, this.initialWidget});

  @override
  Widget build(BuildContext context) {
    return MyApp(initialWidget: initialWidget ?? SignUpPage());
  }
}

class MyApp extends StatelessWidget {
  final Widget? initialWidget;
  const MyApp({super.key, this.initialWidget});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nakoda Ji',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
        ),
      ),
      home: initialWidget ?? SignUpPage(),
    );
  }
}