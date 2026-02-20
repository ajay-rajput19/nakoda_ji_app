import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/screens/dashboard/booking_page.dart';
import 'package:nakoda_ji/apps/member/screens/dashboard/member_dashboard.dart';
import 'package:nakoda_ji/apps/member/screens/dashboard/member_profile.dart';
import 'package:nakoda_ji/apps/member/screens/dashboard/temple_visit_page.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_register_page.dart';
import 'package:nakoda_ji/apps/member/screens/biometric/biometric_booking_page.dart';
import 'package:nakoda_ji/apps/user/backend/user_auth_controller.dart';
import 'package:nakoda_ji/apps/user/screens/auth/user_Login.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/data/static/static_data.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';

class CustomDrawer extends StatelessWidget {
  final bool? isReviewMode;
  final bool? isBiometricMode;
  final String? applicationId;

  const CustomDrawer({
    super.key,
    this.isReviewMode = false,
    this.isBiometricMode = false,
    this.applicationId,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CustomColors.clrWhite,
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(color: CustomColors.clrBtnBg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: CustomColors.clrBtnBg,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Member Name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: CustomFonts.poppins,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "MB-2024-7891",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: CustomFonts.poppins,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: ((isReviewMode ?? false) || (isBiometricMode ?? false))
                  ? [
                      if (isReviewMode ?? false)
                        _buildMenuItem(
                          context,
                          icon: Icons.description,
                          title: "Review Application",
                          onTap: () {
                            Navigator.pop(context);
                            AppNavigation(context).pushReplacement(
                              const MemberRegisterPage(isReviewMode: true),
                            );
                          },
                        ),

                      if ((isBiometricMode ?? false) &&
                          applicationId != null) ...[
                        _buildMenuItem(
                          context,
                          icon: Icons.fingerprint,
                          title: "Biometric Schedule",
                          onTap: () {
                            Navigator.pop(context);
                            AppNavigation(context).pushReplacement(
                              BiometricBookingPage(
                                membershipApplicationId: applicationId!,
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.event_note,
                          title: "My Appointments",
                          onTap: () {
                            Navigator.pop(context);
                            AppNavigation(context).push(
                              BookingPage(
                                applicationId: applicationId,
                                isBiometricMode: true,
                              ),
                            );
                          },
                        ),
                      ],

                      _buildMenuItem(
                        context,
                        icon: Icons.person,
                        title: "Profile",
                        onTap: () {
                          Navigator.pop(context);
                          AppNavigation(
                            context,
                          ).pushReplacement(MemberProfile(isReviewMode: true));
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.logout,
                        title: "Logout",
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          _showLogoutDialog(context);
                        },
                      ),
                    ]
                  : [
                      _buildMenuItem(
                        context,
                        icon: Icons.dashboard,
                        title: "Dashboard",
                        onTap: () {
                          Navigator.pop(context);
                          AppNavigation(
                            context,
                          ).pushReplacement(MemberDashboard());
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.person,
                        title: "Profile",
                        onTap: () {
                          Navigator.pop(context);
                          AppNavigation(
                            context,
                          ).pushReplacement(MemberProfile());
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.book_online,
                        title: "My Bookings",
                        onTap: () {
                          Navigator.pop(context);
                          AppNavigation(context).push(const BookingPage());
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.temple_hindu,
                        title: "Temple Visits",
                        onTap: () {
                          Navigator.pop(context);
                          final staticData = StaticData();
                          AppNavigation(context).push(
                            TempleVisitPage(templeVist: staticData.templeVist),
                          );
                        },
                      ),

                      _buildMenuItem(
                        context,
                        icon: Icons.card_membership,
                        title: "Membership Card",
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.notifications,
                        title: "Notifications",
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to Notifications screen
                        },
                      ),

                      _buildMenuItem(
                        context,
                        icon: Icons.logout,
                        title: "Logout",
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          // Handle Logout
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? CustomColors.clrBtnBg, size: 26),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? CustomColors.clrHeading,
          fontFamily: CustomFonts.poppins,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Logout",
          style: TextStyle(
            fontFamily: CustomFonts.poppins,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: TextStyle(fontFamily: CustomFonts.poppins),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: CustomColors.clrText,
                fontFamily: CustomFonts.poppins,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await UserAuthController.logout();
              if (context.mounted) {
                AppNavigation(context).pushAndRemoveUntil(const UserLogin());
              }
            },
            child: Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontFamily: CustomFonts.poppins,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
