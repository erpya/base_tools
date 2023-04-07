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
  static Future<Client?> getClient() async {
    if (appWriteClient == null) {
      await MovileContext.getEndPoint().then((endPoint) async {
        await MovileContext.getProject().then((project) {
          appWriteClient = Client();
          appWriteClient?.setEndpoint(endPoint!).setProject(project!);
        });
      });
    }

    return appWriteClient;
  }

  ///Get Account
  static Future<Account?> getAccount() async {
    if (MovileApi.account == null) {
      await MovileApi.getClient().then((client) {
        MovileApi.account ??= Account(client!);
      });
    }

    return MovileApi.account;
  }

  //Get Database
  static Future<moviledb.Databases?> getDatabases(String? dataBaseId) async {
    if (database == null) {
      dataBaseId ??= MovileContext.DATABASE_ID_TAG;
      await getClient().then((client) {
        database = moviledb.Databases(client!, dataBaseId!);
      });
    }
    return database;
  }

  //List Documents
  static Future<models.DocumentList?> listDocuments(
      String collectionId, List<String> queryDocument) async {
    models.DocumentList? documents;
    await getDatabases(null).then((database) async {
      await MovileContext.getSessionId().then((sessionId) async {
        await getAccount().then((account) async {
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
        });
      });
    });
    return documents;
  }

  //Create Document
  static Future<models.Document?> createDocument(
      String collectionId, String documentId, Map<String, dynamic> data) async {
    models.Document? document;
    await getDatabases(null).then((database) async {
      await MovileContext.getSessionId().then((sessionId) async {
        await getAccount().then((account) async {
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
        });
      });
    });
    return document;
  }

  ///Get Session Object
  static Future<models.Session?> getSession() async {
    if (MovileApi.session == null) {
      String? sessionId = await MovileContext.getSessionId();
      await MovileApi.getAccount().then((currentAccount) async {
        try {
          await currentAccount!
              .getSession(sessionId: sessionId!)
              .then((currentSession) async {
            setSession(currentSession);
            if (!isValid()) {
              currentAccount
                  .updateSession(sessionId: MovileApi.session!.$id)
                  .then((validSession) {
                setSession(validSession);
              });
            }
          });
        } catch (exception) {
          MovileApi.account = null;
        }
      });
    }

    return MovileApi.session;
  }

  ///Session Valid??
  static bool isValid() {
    if (MovileApi.session != null) {
      //int currentDate = Utils.getIntFromDateTime(DateTime.now());

      DateTime? expire = Utils.castStringToDateTime(MovileApi.session!.expire);
      print((DateTime.now().isAfter(expire!)));
      //print(expire.toString());
      //return true;
      //DateTime expire = new DateTime.parse(formattedString) MovileApi.session!.expire
      // currentDate > MovileApi.session!.expire
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
  static void logout() async {
    await MovileApi.getSession().then((session) async {
      if (session == null) {
        clearSessionData();
      } else {
        await getAccount().then((account) async {
          await account!
              .deleteSession(sessionId: session!.$id)
              .then((deletedSession) => clearSessionData());
        });
      }
    });
  }

  static void clearSessionData() {
    MovileContext.setSessionId("");
    MovileContext.setUserId("");
    MovileContext.setUserName("");
    //MovileContext.setUserEmail("");
  }
}
