import 'package:base_tools/sync/sync_document.dart';

class SyncData {
  static final SyncData _instance = SyncData._syncData();
  int currentSequence = 0;
  String currentDocumentDescription = "";
  final List<SyncDocument> syncDocuments = [];

  SyncData._syncData();

  factory SyncData() {
    return _instance;
  }

  void addDocument(SyncDocument collection) {
    collection.sequence = currentSequence;
    syncDocuments.add(collection);
    currentSequence++;
  }

  Future<void> synchronize() async {
    //_pushDocuments();
    await _pullDocuments();
  }

  Future<void> _pullDocuments() async {
    List<SyncDocument> sortedSyncDocuments =
        syncDocuments.where((collection) => collection.pullable).toList();

    sortedSyncDocuments.sort((collection1, collection2) =>
        collection1.sequence.compareTo(collection2.sequence));
    for (int i = 0; i < sortedSyncDocuments.length; i++) {
      SyncDocument collection = sortedSyncDocuments[i];
      await collection.pull();
    }
  }

  Future<void> _pushDocuments() async {
    List<SyncDocument> sortedSyncDocuments =
        syncDocuments.where((element) => element.pushable).toList();
    sortedSyncDocuments.sort((e1, e2) => e1.sequence.compareTo(e2.sequence));
    for (var document in sortedSyncDocuments) {
      document.push();
    }
  }
}
