import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:base_tools/localization/base_tools_localizations.dart';

enum messageType {
  info,
  error,
  warning,
  question,
}

class MovileMessage {
  BuildContext? context;
  String? tittle;
  String? body;
  String? type;
  BaseToolsLocalizations? localization;
  List<Widget>? actions;

  MovileMessage({
    this.context,
    this.body,
    this.type,
  }) : localization = BaseToolsLocalizations.of(context!);

  String getTittle() {
    switch (type!) {
      case "info":
        return localization!.info;
      case "error":
        return localization!.error;
      case "warning":
        return localization!.warning;
      case "question":
        return localization!.question;
    }
    return "";
  }

  static void showErrorMessage(
      BuildContext context, String bodyMessage, Function() okAction) {
    MovileMessage message = MovileMessage(
      context: context,
      body: bodyMessage,
      type: messageType.error.name,
    );
    message.actions = [
      TextButton(onPressed: okAction, child: const Text("Ok"))
    ];
    message.showMessage();
  }

  void showMessage() {
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context!,
          builder: (ctx) => CupertinoAlertDialog(
                title: Text(
                  getTittle(),
                ),
                content: Text(
                  body!,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text("Ok"))
                ],
              ));
    } else {
      showDialog(
        context: context!,
        builder: (ctx) => AlertDialog(
          title: Text(
            getTittle(),
          ),
          content: Text(
            body!,
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text("Ok"))
          ],
        ),
      );
    }
  }
}
