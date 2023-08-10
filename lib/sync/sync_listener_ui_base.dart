import 'package:base_tools/sync/sync_listener_abstract.dart';
import 'package:base_tools/sync/sync_document.dart';
import 'package:flutter/material.dart';

class SyncListenerUIBase extends SyncListenerAbstract {
  //Constructor
  SyncListenerUIBase(super.context);
  //Start?
  bool start = false;
  //Current Percent
  ValueNotifier<double> currentPercent = ValueNotifier(0);

  @override
  void listener() {
    currentPercent.value =
        targetDocuments == 0 ? 0 : currentDocuments / targetDocuments;
    //Show Progress
    if (state == SyncDocumentState.starting && !start) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ValueListenableBuilder<double>(
              valueListenable: currentPercent,
              builder: (_, msg, __) => Column(
                    children: [
                      Text("$actionTrl $description"),
                      Text("${(msg * 100).ceil()}%"),
                      const SizedBox(
                        height: 10,
                      ),
                      //ChartBar(fill: msg),
                      SizedBox(
                        height: 15,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: LinearProgressIndicator(
                            value: msg,
                            semanticsLabel: description,
                            color: Colors.blue,
                            backgroundColor: Colors.blue.shade50,
                          ),
                        ),
                      ),
                    ],
                  )),
          duration: const Duration(days: 1),
        ),
      );
      if (currentPercent.value == 1) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    }
    //Clear Content at finish
    if (state == SyncDocumentState.done) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    //Show Error
    if (state == SyncDocumentState.error) {
      if (start) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            children: [
              Text("$actionTrl $description"),
              Text(errorMessage),
            ],
          ),
        ),
      );
    }
    setStartSyncDocument();
  }

  setStartSyncDocument() {
    switch (state) {
      case SyncDocumentState.starting:
        start = true;
        break;
      case SyncDocumentState.done:
        start = false;
        break;
      case SyncDocumentState.error:
        start = false;
        break;
      case SyncDocumentState.none:
        start = false;
        break;
    }
  }
}
