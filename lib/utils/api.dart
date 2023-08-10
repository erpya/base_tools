import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:base_tools/utils/movilecontext.dart';
import 'package:base_tools/utils/utils.dart';
import 'package:base_tools/utils/database.dart' as moviledb;

class MovileApi {
  static Client? appWriteClient;
  static Account? account;
  static moviledb.Databases? database;
  static models.Session? session;

  /// Get Client
  static Client? getClient() {
    if (appWriteClient == null) {
      String? endPoint = MovileContext.getEndPoint();
      String? project = MovileContext.getProject();
      appWriteClient = Client();
      appWriteClient?.setEndpoint(endPoint!).setProject(project!);
    }

    return appWriteClient;
  }

  ///Get Account
  static Account? getAccount() {
    if (MovileApi.account == null) {
      Client? client = MovileApi.getClient();
      MovileApi.account ??= Account(client!);
    }

    return MovileApi.account;
  }

  //Get Database
  static moviledb.Databases? getDatabases(String? dataBaseId) {
    if (database == null) {
      dataBaseId ??= MovileContext.DATABASE_ID_TAG;
      Client? client = getClient();
      database = moviledb.Databases(client!, dataBaseId);
    }
    return database;
  }

  //List Documents
  static Future<models.DocumentList?> listDocuments(
      String collectionId, List<String> queryDocument) async {
    models.DocumentList? documents;
    moviledb.Databases? database = getDatabases(null);
    String? sessionId = MovileContext.getSessionId();
    Account? account = getAccount();
    await account!.getSession(sessionId: sessionId!).then((value) async {
      await database!
          .listDocuments(
              databaseId: database.id,
              collectionId: collectionId,
              queries: queryDocument)
          .then((documentList) {
        documents = documentList;
      });
    });

    return documents;
  }

  //Create Document
  static Future<models.Document?> createDocument(
      String collectionId, String documentId, Map<String, dynamic> data) async {
    models.Document? document;
    moviledb.Databases? database = getDatabases(null);
    String? sessionId = MovileContext.getSessionId();
    Account? account = getAccount();
    await account!.getSession(sessionId: sessionId!).then((value) async {
      await database!
          .createDocument(
              databaseId: database.id,
              collectionId: collectionId,
              documentId: documentId,
              data: data)
          .then((currentDocument) {
        document = currentDocument;
      });
    });
    return document;
  }

  ///Get Session Object
  static Future<models.Session?> getSession() async {
    String? sessionId = MovileContext.getSessionId();
    if (MovileApi.session == null && (sessionId ?? "").isNotEmpty) {
      Account? currentAccount = MovileApi.getAccount();
      try {
        await currentAccount!
            .getSession(sessionId: sessionId!)
            .then((currentSession) async {
          setSession(currentSession);
          if (!isValid()) {
            await currentAccount
                .updateSession(sessionId: MovileApi.session!.$id)
                .then((validSession) {
              setSession(validSession);
            });
          }
        });
      } catch (exception) {
        MovileApi.account = null;
      }
    }

    return MovileApi.session;
  }

  ///Session Valid??
  static bool isValid() {
    if (MovileApi.session != null) {
      DateTime? expire = Utils.castStringToDateTime(MovileApi.session!.expire);
      return (DateTime.now().isAfter(expire!));
    } else {
      return false;
    }
  }

  ///Set Session
  static void setSession(models.Session session) {
    MovileApi.session = session;
    MovileContext.setSessionId(MovileApi.session!.$id);
  }

  //Logout
  static Future<void> logout() async {
    //bool isLogout = false;
    await MovileApi.getSession().then((session) async {
      if (session == null) {
        clearSessionData();
      } else {
        Account? account = getAccount();
        await account!
            .deleteSession(sessionId: session.$id)
            .then((deletedSession) => clearSessionData())
            .catchError((error) {
          throw AppwriteException(error.message);
        });
      }
    });
    //return isLogout;
  }

  static void clearSessionData() {
    MovileContext.setSessionId("");
    MovileContext.setUserId("");
    MovileContext.setUserName("");
    MovileContext.setUserEmail("");
  }
}
