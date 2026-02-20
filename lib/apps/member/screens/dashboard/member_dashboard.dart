import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/components/header_row.dart';
import 'package:nakoda_ji/apps/member/components/member_card.dart';
import 'package:nakoda_ji/apps/member/components/booking_crad_list.dart';
import 'package:nakoda_ji/apps/member/components/temple_visit_card.dart';
import 'package:nakoda_ji/apps/member/screens/dashboard/booking_page.dart';
import 'package:nakoda_ji/apps/member/screens/dashboard/temple_visit_page.dart';
import 'package:nakoda_ji/components/appbar/commen_appbar.dart';
import 'package:nakoda_ji/components/appbar/custom_drawer.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';
import 'package:nakoda_ji/data/static/static_data.dart';
import 'package:nakoda_ji/utils/app_navigations/app_navigation.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final StaticData staticData = StaticData();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CommonAppBar(scaffoldKey: _scaffoldKey),
        endDrawer: CustomDrawer(),
        backgroundColor: CustomColors.clrbg,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            // color: CustomColors.clrWhite,
            borderRadius: BorderRadius.circular(10),
          ),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashbaord",
                  style: TextStyle(
                    color: CustomColors.clrBlack,
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    fontFamily: CustomFonts.poppins,
                  ),
                ),
                SizedBox(height: 15),
                MemberCard(
                  membershipId: "MB-2024-7891",
                  onDownload: () {
                    print("Download button clicked!");
                  },
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CustomColors.clrWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      HeaderRow(
                        headerIcon: Icons.list,
                        headerBgColor: CustomColors.clrCradBg,
                        iconColor: CustomColors.clrForgotPass,
                        title: "Upcoming Bookings",
                        actionText: "View All",
                        onActionTap: () {
                          AppNavigation(
                            context,
                          ).push(const BookingPage());
                        },
                      ),
                      SizedBox(height: 15),
                      ListView.builder(
                        itemCount: staticData.bookings.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SectionCradList(
                              booking: staticData.bookings[index],
                            ),
                          );
                        },
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
                  ),
                  child: Column(
                    children: [
                      HeaderRow(
                        headerIcon: Icons.list,
                        headerBgColor: CustomColors.clrtempleBg,
                        iconColor: CustomColors.clrtempleStatus,
                        title: "Recent Temple Visits",
                        actionText: "View All",
                        onActionTap: () {
                          AppNavigation(context).push(
                            TempleVisitPage(templeVist: staticData.templeVist),
                          );
                        },
                      ),
                      SizedBox(height: 15),
                      ListView.builder(
                        itemCount: staticData.templeVist.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: TempleVisitCard(
                              visit: staticData.templeVist[index],
                            ),
                          );
                        },
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
