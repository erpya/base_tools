import 'package:base_tools/localization/base_tools_localizations.dart';
import 'package:base_tools/sync/sync_document.dart';
import 'package:flutter/material.dart';

abstract class SyncListenerAbstract {
  //Sync Document
  SyncDocument? syncDocument;
  //Context
  BuildContext context;
  //Localization
  BaseToolsLocalizations localization;

  //Constructor
  SyncListenerAbstract(this.context)
      : localization = BaseToolsLocalizations.of(context)!;

  //Set Document Listener
  void setSyncDocumentListener(SyncDocument syncDocument) {
    this.syncDocument = syncDocument;
  }

  //Get Description
  get description {
    return syncDocument != null ? syncDocument!.description : "";
  }

  //Get Action
  get action {
    return syncDocument != null
        ? syncDocument!.currentAction
        : SyncDocumentAction.nothing;
  }

  //Get State
  get state {
    return syncDocument != null
        ? syncDocument!.currentState
        : SyncDocumentState.none;
  }

  //Get Current Documents Count
  get currentDocuments {
    return syncDocument!.currentDocuments;
  }

  //Get Target Documents Count
  get targetDocuments {
    return syncDocument != null ? syncDocument!.targetDocuments : 0;
  }

  //Get Document Name
  get name {
    return syncDocument != null ? syncDocument!.name : "";
  }

  //Get Percentage
  get percent {
    return syncDocument != null ? syncDocument!.percent : 0;
  }

  get actionTrl {
    switch (syncDocument!.currentAction) {
      case SyncDocumentAction.getting:
        return localization.downloading;
      case SyncDocumentAction.saving:
        return localization.saving;
      default:
        return "";
    }
  }

  get errorMessage {
    return syncDocument != null ? syncDocument!.errorMessage : "";
  }

  //Abstract Listener Method
  void listener();
}
