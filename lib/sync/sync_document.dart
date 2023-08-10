import 'package:appwrite/appwrite.dart';
import 'package:base_tools/sync/api_document.dart';
import 'package:base_tools/sync/api_documentstate.dart';
import 'package:base_tools/sync/sync_listener_abstract.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum SyncDocumentAction {
  saving,
  getting,
  sending,
  nothing,
  finnish,
}

enum SyncDocumentState {
  none,
  starting,
  done,
  error,
}

const actionIcons = {
  SyncDocumentAction.saving: Icons.save,
  SyncDocumentAction.getting: Icons.download,
  SyncDocumentAction.sending: Icons.upload,
  SyncDocumentAction.nothing: Icons.do_not_disturb,
  SyncDocumentAction.finnish: Icons.done,
};

class SyncDocument with ChangeNotifier {
  //Api Document
  ApiDocumentState collection;
  //Is Pullable?
  bool pullable;
  //Is Pushable?
  bool pushable;
  //Document Name
  String name;
  //Document Description
  String description;
  //Sequence
  int sequence;
  //Target documents to Send or Get
  int targetDocuments = 0;
  //Current Document Send or Get
  int currentDocuments = 0;
  //Current Page Data
  int currentPage = 0;
  //Total Page
  num totalPage = 0;
  //Records per Page
  int recordsPerPage = 25;
  //Current Action
  SyncDocumentAction currentAction;
  //Current State
  SyncDocumentState currentState;
  //Error Message
  String errorMessage;
  //Constructor
  SyncDocument({
    required this.collection,
    this.pullable = false,
    this.pushable = false,
    this.sequence = 0,
    this.description = "",
    this.currentAction = SyncDocumentAction.nothing,
    this.currentState = SyncDocumentState.none,
    this.errorMessage = "",
  }) : name = collection.documentBoxName!;

  SyncDocument addListenerClass(SyncListenerAbstract listener) {
    addListener(listener.listener);
    listener.setSyncDocumentListener(this);
    return this;
  }

  //Pull Documents
  Future<void> pull() async {
    await _pullDocumentsFromAPI().then((documents) async {
      await _pushDocumentToDB(documents!);
    }).catchError((error) {
      errorMessage = error.message;
      currentState = SyncDocumentState.error;
      notifyListeners();
    });
    ;
  }

  //Push Documents to DB
  Future<void> _pushDocumentToDB(List<ApiDocument> documents) async {
    final documentDB = await Hive.openBox(name);
    currentAction = SyncDocumentAction.saving;
    currentState = SyncDocumentState.starting;
    if (documents.isNotEmpty) await documentDB.clear();
    targetDocuments = documents.length;
    currentDocuments = 0;
    notifyListeners();
    for (int i = 0; i < documents.length; i++) {
      ApiDocument document = documents[i];
      await collection.parseDocumentDB(documentDB, document);
      currentDocuments++;
      if (currentDocuments == targetDocuments) {
        currentState = SyncDocumentState.done;
      }
      //Notify Listeners
      notifyListeners();
    }
  }

  //Pull Documents from API
  Future<List<ApiDocument>?> _pullDocumentsFromAPI() async {
    currentAction = SyncDocumentAction.getting;
    currentState = SyncDocumentState.starting;
    totalPage = 1;
    currentPage = 0;
    currentDocuments = 0;
    targetDocuments = 0;
    notifyListeners();
    List<ApiDocument> documents = [];

    while (currentPage < totalPage) {
      List<String>? currentQuery = [];
      currentQuery.add(Query.limit(recordsPerPage));
      currentQuery.add(Query.offset(recordsPerPage * currentPage));

      await collection.listDocuments(currentQuery).then((retrievedDocuments) {
        targetDocuments = retrievedDocuments!["total"];
        totalPage = (targetDocuments / recordsPerPage).ceil();
        documents.addAll(retrievedDocuments["documents"]);
        currentDocuments = documents.length;
      });
      currentPage++;
      currentQuery = [];
      if (currentDocuments == targetDocuments &&
          currentState != SyncDocumentState.error) {
        currentState = SyncDocumentState.done;
      }
      //Notify Listeners
      notifyListeners();
    }

    return documents;
  }

  //Push Documents to API
  Future<void> push() async {
    //collection.pushPendingDocuments();
  }

  Future<void> _pushDocumentsToAPI() async {
    final documentDB = await Hive.openBox(name);

    documentDB.values
        .where((localDocument) => !localDocument.synchronized)
        .forEach((localDocument) async {
      await collection
          .parseDBDocument(localDocument, collection.document)
          .then((documentToSent) async {
        if (documentToSent != null) {
          await collection
              .pushDocument(documentToSent.getId()!, documentToSent.toJSON())
              .then((documentCreated) {
            localDocument.synchronized = true;
            documentDB.put(localDocument.uuid, localDocument);
          });
        }
      });
    });
  }

  //Get Percent
  int get percent {
    num percent =
        targetDocuments == 0 ? 0 : (currentDocuments / targetDocuments) * 100;
    return percent.floor();
  }
}
