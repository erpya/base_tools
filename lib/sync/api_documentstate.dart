import 'package:appwrite/appwrite.dart';
import 'package:hive/hive.dart';
import 'package:base_tools/sync/api_document.dart';
import 'package:base_tools/utils/api.dart';
import 'package:base_tools/utils/movilecontext.dart';
import 'package:base_tools/utils/utils.dart';

abstract class ApiDocumentState {
  String? collectionId;
  String? documentBoxName;
  final List<String>? _query = [];
  final List<ApiDocument>? _documents = [];
  final ApiDocument? _document;

  ApiDocumentState(this.collectionId, this.documentBoxName, this._document);

  parseDocumentDB(Box localDocument, dynamic apiDocument);
  Future<ApiDocument?> parseDBDocument(
      dynamic localDocument, dynamic apiDocument);

  String _getDocumentUpdateTag() {
    if (collectionId != null) {
      return "$collectionId";
    } else {
      return "";
    }
  }

  ApiDocumentState addRestriction(String restriction) {
    _query!.add(restriction);
    return this;
  }

  Future<int?> getLastUpdated() async {
    int? lastUpdated = 0;
    await MovileContext.getIntegerValue(_getDocumentUpdateTag())
        .then((lastUpdatedFromContext) {
      if (lastUpdatedFromContext != null && lastUpdatedFromContext != 0) {
        lastUpdated = lastUpdatedFromContext;
      }
    });
    return lastUpdated;
  }

  setLastUpdated() async {
    await MovileContext.setStringValue(
        _getDocumentUpdateTag(), DateTime.now().toString());
  }

  Future<void> pendingForDownload() async {
    _query!.clear;
    await getLastUpdated().then((lastUpdated) {
      if (lastUpdated! > 0) {
        _query!.add(Query.greaterThanEqual("\$updatedAt", lastUpdated!));
      }
    });
  }

  Future<List<ApiDocument>?> listAllDocuments() async {
    _query!.clear();
    return _listDocuments();
  }

  Future<List<ApiDocument>?> listPendingForDownloadDocuments() async {
    await pendingForDownload();
    return _listDocuments();
  }

  Future<List<ApiDocument>?> _listDocuments() async {
    int currentPage = 0;
    num totalPage = 1;
    int records = 25;
    while (currentPage < totalPage) {
      List<String>? currentQuery = [];
      currentQuery = _query!.toList(growable: true);
      currentQuery.add(Query.limit(records));
      currentQuery.add(Query.offset(records * currentPage));
      await MovileApi.listDocuments(collectionId!, currentQuery!)
          .then((retrievedDocuments) {
        totalPage = (retrievedDocuments!.total / records).ceil();
        retrievedDocuments!.documents.forEach((retrievedJSON) {
          _document!.fromJSON(retrievedJSON.data);
          _documents!.add(_document!.copy());
        });
      });
      currentPage++;
      currentQuery = [];
    }
    return _documents;
  }

  Future<ApiDocument?> _createDocument(
      String documentId, Map<String, dynamic> data) async {
    await MovileApi.createDocument(collectionId!, documentId, data)
        .then((retrievedDocument) {
      _document!.fromJSON(retrievedDocument!.data);
    });

    return _document;
  }

  Future<void> updateLocalData() async {
    final documentDB = await Hive.openBox(documentBoxName!);
    //await pendingForDownload();
    await _listDocuments().then((documents) async {
      if (documents!.isNotEmpty) await documentDB.clear();
      documents!.forEach((element) async {
        await parseDocumentDB(documentDB, element);
      });
      await setLastUpdated();
    });
  }

  Future<void> updateExternalData() async {
    final documentDB = await Hive.openBox(documentBoxName!);
    documentDB.values
        .where((localDocument) => !localDocument.synchronized)
        .forEach((localDocument) async {
      await parseDBDocument(localDocument, _document)
          .then((documentToSent) async {
        if (documentToSent != null) {
          await _createDocument(
                  documentToSent.getId()!, documentToSent.toJSON())
              .then((documentCreated) {
            localDocument.synchronized = true;
            documentDB.put(localDocument.uuid, localDocument);
          });
        }
      });
    });
  }
}
