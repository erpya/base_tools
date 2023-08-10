import 'package:appwrite/appwrite.dart';
import 'package:hive/hive.dart';
import 'package:base_tools/sync/api_document.dart';
import 'package:base_tools/utils/api.dart';
import 'package:base_tools/utils/movilecontext.dart';

abstract class ApiDocumentState {
  final String? _collectionId;
  final String? documentBoxName;
  final List<String> _query = [];
  final List<ApiDocument> _documents = [];
  final ApiDocument? _document;

  ApiDocumentState(this._collectionId, this.documentBoxName, this._document);

  get document {
    return _document;
  }

  get collectionId {
    return _collectionId;
  }

  parseDocumentDB(Box localDocument, dynamic apiDocument);
  Future<ApiDocument?> parseDBDocument(
      dynamic localDocument, dynamic apiDocument);

  String _getDocumentUpdateTag() {
    if (_collectionId != null) {
      return "$_collectionId";
    } else {
      return "";
    }
  }

  ApiDocumentState addRestriction(String restriction) {
    _query.add(restriction);
    return this;
  }

  @deprecated
  Future<int?> getLastUpdated() async {
    return MovileContext.getIntegerValue(_getDocumentUpdateTag()) ?? 0;
  }

  @deprecated
  setLastUpdated() async {
    await MovileContext.setStringValue(
        _getDocumentUpdateTag(), DateTime.now().toString());
  }

  @deprecated
  Future<void> pendingForDownload() async {
    _query.clear;
    await getLastUpdated().then((lastUpdated) {
      if (lastUpdated! > 0) {
        _query.add(Query.greaterThanEqual("\$updatedAt", lastUpdated));
      }
    });
  }

  @deprecated
  Future<List<ApiDocument>?> listAllDocuments() async {
    _query.clear();
    return _listDocuments();
  }

  @deprecated
  Future<List<ApiDocument>?> listPendingForDownloadDocuments() async {
    await pendingForDownload();
    return _listDocuments();
  }

  @deprecated
  Future<List<ApiDocument>?> _listDocuments() async {
    int currentPage = 0;
    num totalPage = 1;
    int records = 25;
    while (currentPage < totalPage) {
      List<String>? currentQuery = [];
      currentQuery = _query.toList(growable: true);
      currentQuery.add(Query.limit(records));
      currentQuery.add(Query.offset(records * currentPage));
      await MovileApi.listDocuments(_collectionId!, currentQuery)
          .then((retrievedDocuments) {
        totalPage = (retrievedDocuments!.total / records).ceil();
        retrievedDocuments.documents.forEach((retrievedJSON) {
          _document!.fromJSON(retrievedJSON.data);
          _documents.add(_document!.copy());
        });
      });
      currentPage++;
      currentQuery = [];
    }
    return _documents;
  }

  Future<Map<String, dynamic>?> listDocuments(
      List<String> queryDocument) async {
    final Map<String, dynamic> data = {};
    _documents.clear();
    await MovileApi.listDocuments(_collectionId!, queryDocument)
        .then((retrievedDocuments) {
      data.addAll({"total": retrievedDocuments!.total});
      retrievedDocuments.documents.forEach((retrievedJSON) {
        _document!.fromJSON(retrievedJSON.data);
        _documents.add(_document!.copy());
      });
      data.addAll({"documents": _documents});
    });
    return data;
  }

  Future<ApiDocument?> pushDocument(
      String documentId, Map<String, dynamic> data) async {
    await MovileApi.createDocument(_collectionId!, documentId, data)
        .then((retrievedDocument) {
      _document!.fromJSON(retrievedDocument!.data);
    });

    return _document;
  }

  @deprecated
  Future<void> updateLocalData() async {
    final documentDB = await Hive.openBox(documentBoxName!);
    //await pendingForDownload();
    await _listDocuments().then((documents) async {
      if (documents!.isNotEmpty) await documentDB.clear();
      documents.forEach((element) async {
        await parseDocumentDB(documentDB, element);
      });
      await setLastUpdated();
    });
  }

  @deprecated
  Future<void> pushPendingDocuments() async {
    final documentDB = await Hive.openBox(documentBoxName!);
    documentDB.values
        .where((localDocument) => !localDocument.synchronized)
        .forEach((localDocument) async {
      await parseDBDocument(localDocument, _document)
          .then((documentToSent) async {
        if (documentToSent != null) {
          await pushDocument(documentToSent.getId()!, documentToSent.toJSON())
              .then((documentCreated) {
            localDocument.synchronized = true;
            documentDB.put(localDocument.uuid, localDocument);
          });
        }
      });
    });
  }

  @deprecated
  Future<void> pullPendingDocuments() async {
    final documentDB = await Hive.openBox(documentBoxName!);
    //await pendingForDownload();
    await _listDocuments().then((documents) async {
      if (documents!.isNotEmpty) await documentDB.clear();
      documents.forEach((element) async {
        await parseDocumentDB(documentDB, element);
      });
      await setLastUpdated();
    });
  }
}
