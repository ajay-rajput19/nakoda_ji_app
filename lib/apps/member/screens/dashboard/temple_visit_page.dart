import 'package:flutter/material.dart';
import 'package:nakoda_ji/apps/member/components/temple_visit_card.dart';
import 'package:nakoda_ji/backend/models/temple_vist_model.dart';
import 'package:nakoda_ji/components/appbar/commen_appbar.dart';
import 'package:nakoda_ji/components/appbar/custom_drawer.dart';
import 'package:nakoda_ji/data/static/color_export.dart';
import 'package:nakoda_ji/data/static/custom_fonts.dart';

class TempleVisitPage extends StatefulWidget {
  final List<TempleVistModel> templeVist;

  const TempleVisitPage({super.key, required this.templeVist});

  @override
  State<TempleVisitPage> createState() => _TempleVisitPageState();
}

class _TempleVisitPageState extends State<TempleVisitPage> {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "All Temple Visits",
                style: TextStyle(
                  color: CustomColors.clrBlack,
                  fontWeight: FontWeight.w500,
                  fontSize: 25,
                  fontFamily: CustomFonts.poppins,
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: widget.templeVist.isEmpty
                    ? Center(
                        child: Text(
                          "No temple visits available",
                          style: TextStyle(
                            fontSize: 16,
                            color: CustomColors.clrText,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.templeVist.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: TempleVisitCard(
                              visit: widget.templeVist[index],
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
