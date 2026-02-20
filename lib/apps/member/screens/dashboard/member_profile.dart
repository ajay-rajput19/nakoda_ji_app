import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/screens/auth/member_choose_form.dart';
import 'package:nakoda_ji/apps/member/components/document_card.dart';
import 'package:nakoda_ji/apps/member/components/profile_header.dart';
import 'package:nakoda_ji/apps/member/components/profile_row_data.dart';
import 'package:nakoda_ji/apps/member/components/info.dart';
import 'package:nakoda_ji/components/appbar/commen_appbar.dart';
import 'package:nakoda_ji/components/appbar/custom_drawer.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';

class MemberProfile extends StatefulWidget {
  final bool isReviewMode;
  const MemberProfile({super.key, this.isReviewMode = false});

  @override
  State<MemberProfile> createState() => _MemberProfileState();
}

class _MemberProfileState extends State<MemberProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: CustomColors.clrbg,
        appBar: CommonAppBar(scaffoldKey: _scaffoldKey),
        endDrawer: CustomDrawer(isReviewMode: widget.isReviewMode),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    AppNavigation(context).push(MemberChooseForm());
                  },
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      color: CustomColors.clrBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                      fontFamily: CustomFonts.poppins,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Profile Header with Avatar
                ProfileHeader(
                  memberName: "Raj Kumar",
                  memberId: "MB-2024-7891",
                  memberStatus: "Active Member",
                ),

                SizedBox(height: 20),

                // Personal Information Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CustomColors.clrWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: CustomColors.clrBtnBg,
                            size: 30,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Personal Information",
                            style: TextStyle(
                              color: CustomColors.clrHeading,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: CustomFonts.poppins,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ProfileRowData(label: "Full Name", value: "Raj Kumar"),
                      Divider(
                        color: const Color.fromARGB(255, 224, 225, 228),
                        height: 20,
                      ),
                      ProfileRowData(
                        label: "Email Address",
                        value: "raj.kumar@example.com",
                      ),
                      Divider(
                        color: const Color.fromARGB(255, 224, 225, 228),
                        height: 20,
                      ),
                      ProfileRowData(
                        label: "Phone Number",
                        value: "+91 98765 43210",
                      ),
                      Divider(
                        color: const Color.fromARGB(255, 224, 225, 228),
                        height: 20,
                      ),
                      ProfileRowData(
                        label: "Date of Birth",
                        value: "15 June 1990",
                      ),
                      Divider(
                        color: const Color.fromARGB(255, 224, 225, 228),
                        height: 20,
                      ),
                      ProfileRowData(label: "Gender", value: "Male"),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CustomColors.clrWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      DocumentCard(
                        iconColor: CustomColors.clrForgotPass,
                        icon: Icons.file_copy,
                        title: "Income Certificate",
                        subtitle: "Uploaded: 15 Jan 2024",
                        status: "Verified",
                        statusIcon: Icons.check_circle,
                      ),
                      DocumentCard(
                        iconColor: CustomColors.clrForgotPass,
                        icon: Icons.file_copy,
                        title: "Address Proof",
                        subtitle: "Uploaded: 20 Jan 2024",
                        status: "Pending",
                        statusIcon: Icons.access_time,
                      ),
                      DocumentCard(
                        iconColor: CustomColors.clrForgotPass,
                        icon: Icons.file_copy,
                        title: "Address Proof",
                        subtitle: "Uploaded: 20 Jan 2024",
                        status: "Verified",
                        statusIcon: Icons.access_time,
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                "Upload New Document",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CustomColors.clrWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bar_chart,
                            color: CustomColors.clrBtnBg,
                            size: 30,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Quick Stats",
                            style: TextStyle(
                              color: CustomColors.clrHeading,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: CustomFonts.poppins,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),

                      InfoItemRow(
                        title: "Documents Verified",
                        value: "2/3",
                        icon: Icons.access_time,
                      ),
                      InfoItemRow(
                        title: "Documents Verified",
                        value: "2/3",
                        icon: Icons.file_copy,
                      ),
                      InfoItemRow(
                        title: "Security Score",
                        value: "2/3",
                        icon: Icons.security,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CustomColors.clrWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: CustomColors.clrBtnBg,
                            size: 30,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Recent Activity",
                            style: TextStyle(
                              color: CustomColors.clrHeading,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: CustomFonts.poppins,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      InfoItemRow(
                        title: "Aadhar card verified",
                        time: "2 days ago",
                        dot: InfoDotType.green,
                      ),

                      InfoItemRow(
                        title: "Profile updated",
                        time: "1 week ago",
                        dot: InfoDotType.blue,
                      ),
                      InfoItemRow(
                        title: "Jan Aadhar uploaded",
                        time: "2 weeks ago",
                        dot: InfoDotType.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
