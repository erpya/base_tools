import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:base_tools/localization/base_tools_localizations.dart';

class Location {
  static Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  static Future<bool> handleLocationPermission(BuildContext context) async {
    BaseToolsLocalizations? localization = BaseToolsLocalizations.of(context);
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localization!.locationDisabled)));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localization!.locationDenied)));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localization!.locationPermanentlyDenied)));
      return false;
    }
    return true;
  }
}
