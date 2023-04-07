import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pin_lock/pin_lock.dart';

class Utils {
  static GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey = null;
  static String formatAmount(num value) {
    var format = NumberFormat("###,###,###,###,##0.00");
    if (!kIsWeb) {
      format = NumberFormat("###,###,###,###,##0.00", Platform.localeName);
    }
    return format.format(value);
  }

  static String formatQuantity(num value) {
    var format = NumberFormat("###,###,###,###,##0.00");
    return format.format(value);
  }

  static Future<Authenticator> getPinAuthenticator() async {
    return await PinLock.baseAuthenticator('1');
  }

  static DateTime? castStringToDateTime(String? stringDate) {
    DateTime? currentDate;
    if (stringDate != null) currentDate = DateTime.parse(stringDate).toLocal();
    return currentDate;
  }

  static GlobalKey<ScaffoldMessengerState>? getScaffoldMessengerState() {
    scaffoldMessengerKey ??= GlobalKey<ScaffoldMessengerState>();
    return scaffoldMessengerKey;
  }

  static showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.fixed,
            content: Text(message)));
  }
}
