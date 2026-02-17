import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_choose_form.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_register_page.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_status_page.dart';
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
      // Check if user has an existing application
      bool hasApp = prefs.getBool('hasMembershipApplication') ?? false;
      String? appId = prefs.getString('memberRegistrationApplicationId');
      
      // Also check if there's a saved registration step locally
      int savedStep = prefs.getInt(LocalStorage.memberRegistrationStep) ?? 0;
      
      if (hasApp && appId != null) {
        // User already has a submitted application, show status page
        initialWidget = MemberStatusPage(
          applicationId: appId,
          onEdit: () {
            Get.offAll(() => const MemberRegisterPage());
          },
        );
      } else if (savedStep > 0) {
        // User is in the middle of a draft
        initialWidget = const MemberRegisterPage();
      } else {
        // New user or no application yet
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