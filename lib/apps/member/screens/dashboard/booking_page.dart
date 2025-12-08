import 'package:flutter/material.dart';
import 'package:nakoda_ji/backend/models/booking_model.dart';
import 'package:nakoda_ji/apps/member/components/booking_crad_list.dart';
import 'package:nakoda_ji/components/appbar/commen_appbar.dart';
import 'package:nakoda_ji/components/appbar/custom_drawer.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class BookingPage extends StatefulWidget {
  final List<BookingModel> bookings;

  const BookingPage({super.key, required this.bookings});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return
     SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CommonAppBar(scaffoldKey: _scaffoldKey),
        endDrawer: CustomDrawer(),

        backgroundColor: CustomColors.clrbg,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "All Bookings",
                style: TextStyle(
                  color: CustomColors.clrBlack,
                  fontWeight: FontWeight.w500,
                  fontSize: 25,
                  fontFamily: CustomFonts.poppins,
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: widget.bookings.isEmpty
                    ? Center(
                        child: Text(
                          "No bookings available",
                          style: TextStyle(
                            fontSize: 16,
                            color: CustomColors.clrText,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.bookings.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SectionCradList(
                              booking: widget.bookings[index],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
