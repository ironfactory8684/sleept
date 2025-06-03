import 'package:flutter/material.dart';

IconData? getStampIcon(String? type) {
  switch (type) {
    case 'moon':
      return Icons.nightlight_round;
    case 'water':
      return Icons.water_drop;
    case 'gear':
      return Icons.settings;
    default:
      return null;
  }
}

Color getStampIconColor(String? type) {
  switch (type) {
    case 'moon':
      return Colors.blueAccent;
    case 'water':
      return Colors.lightBlueAccent;
    case 'gear':
      return Colors.grey;
    default:
      return Colors.transparent;
  }
}
