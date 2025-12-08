import 'package:flutter/material.dart';

class BookingModel {
  final String title;
  final String date;
  final String time;
  final String description;
  final String duration;
  final String status;
  final Color statusColor;
  final Color bgColor;

  BookingModel({
    required this.title,
    required this.date,
    required this.time,
    required this.description,
    required this.duration,
    required this.status,
    required this.statusColor,
    required this.bgColor,
  });
}
