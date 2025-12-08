import 'package:nakoda_ji/backend/models/booking_model.dart';
import 'package:nakoda_ji/backend/models/temple_vist_model.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

class StaticData {
  List<BookingModel> bookings = [
    BookingModel(
      title: "Prayer Hall A",
      date: "12/12/2022",
      time: "10:12",
      description: "description",
      duration: "10 min",
      status: "Completed",
      statusColor: CustomColors.clrForgotPass,
      bgColor: CustomColors.clrCradBg,
    ),
    BookingModel(
      title: "Community Hall",
      date: "12/12/2022",
      time: "10:12",
      description: "description",
      duration: "10 min",
      status: "Pending",
      statusColor: CustomColors.clrStatusPending,
      bgColor: CustomColors.clrCradbgTwo,
    ),
  ];

  List<TempleVistModel> templeVist = [
    TempleVistModel(
      title: "Morning Darshan",
      date: "12/12/2022",
      time: "10:12",
      description: "description",
      duration: "10 min",
      status: "Completed",
      statusColor: CustomColors.clrtempleStatus,
      bgColor: CustomColors.clrtempleBg,
    ),
    TempleVistModel(
      title: "Special Puja",
      date: "12/12/2022",
      time: "10:12",
      description: "description",
      duration: "10 min",
      status: "Pending",
      statusColor: CustomColors.clrtempleStatusTwo,
      bgColor: CustomColors.clrtempleBgTwo,
    ),
  ];
}
