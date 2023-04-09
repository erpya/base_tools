import 'package:appwrite/appwrite.dart';
import 'package:base_tools/sync/sync_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/base_tools_localizations.dart';
import 'package:base_tools/utils/utils.dart';

class SyncData {
  static Duration longDuration = const Duration(days: 365);
  static Duration shortDuration = const Duration(seconds: 5);
  static Future<void> downloadData(
      AppLocalizations localization, SyncHandler? handler, bool isBackground) async {
    try {
      if(handler != null) {
        handler.synchronize();
      }
    } catch (e) {
      AppwriteException? ex;
      String erroMessage = "";
      if (e is AppwriteException) ex = e;

      if (ex != null) {
        erroMessage = ex.message!;
      } else {
        erroMessage = e.toString();
      }

      _showMessage("$erroMessage!", isBackground);
    }
  }

  static _showAction(String action, String document, bool isBackground) {
    _showNotification("$action $document", isBackground, longDuration, false);
  }

  static _showMessage(String errorMessage, bool isBackground) {
    _showNotification(errorMessage, isBackground, shortDuration, true);
  }

  static _showNotification(
      String message, bool isBackground, Duration duration, bool showProgress) {
    if (isBackground) {
      print(message);
    } else {
      Utils.getScaffoldMessengerState()!.currentState!.clearSnackBars();
      if (!showProgress) {
        Utils.getScaffoldMessengerState()!.currentState!.showSnackBar(SnackBar(
              content: Row(
                children: [
                  const SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(color: Colors.blue)),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(message),
                ],
              ),
              elevation: 10,
              duration: duration,
            ));
      } else {
        Utils.getScaffoldMessengerState()!.currentState!.showSnackBar(SnackBar(
            content: Text(message), elevation: 10, duration: duration));
      }
    }
  }
}
