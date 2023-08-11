import 'package:appwrite/models.dart';
import 'package:hive/hive.dart';
import 'package:base_tools/sync/api_document.dart';
import 'package:base_tools/utils/api.dart';

abstract class ApiDocumentState {
  //Collection Identifier
  final String? _collectionId;
  //Document Box Name
  final String? documentBoxName;
  //Filter Data
  final List<String> _query = [];
  // Api Document
  final ApiDocument? _document;

  ApiDocumentState(this._collectionId, this.documentBoxName, this._document);

  //Get Document
  get document {
    return _document;
  }

  //Get Collection Identifier
  get collectionId {
    return _collectionId;
  }

  parseDocumentDB(Box localDocument, dynamic apiDocument);
  Future<ApiDocument?> parseDBDocument(
      dynamic localDocument, dynamic apiDocument);

  //Add Restriction
  ApiDocumentState addRestriction(String restriction) {
    _query.add(restriction);
    return this;
  }

  //Clear Restriction
  clearRestrictions() {
    _query.clear();
  }

  Future<Map<String, dynamic>?> listDocuments(
      List<String> queryDocument) async {
    final Map<String, dynamic> data = {};
    final List<ApiDocument> documents = [];
    await MovileApi.listDocuments(_collectionId!, queryDocument)
        .then((retrievedDocuments) {
      data.addAll({"total": retrievedDocuments!.total});
      for (int i = 0; i < retrievedDocuments.documents.length; i++) {
        Document retrievedJSON = retrievedDocuments.documents[i];
        _document!.fromJSON(retrievedJSON.data);
        documents.add(_document!.copy());
      }
      data.addAll({"documents": documents});
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
}
