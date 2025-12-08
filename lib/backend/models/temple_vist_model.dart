import 'package:flutter/material.dart';

class TempleVistModel {
  final String title;
  final String date;
  final String time;
  final String description;
  final String duration;
  final String status;
  final Color statusColor;
  final Color bgColor;

  TempleVistModel({
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
