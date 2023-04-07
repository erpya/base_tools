import 'package:shared_preferences/shared_preferences.dart';

class MovileContext {
  /// End Point Tag
  static const String ENDPOINT_TAG = "EndPoint";

  /// Project Tag
  static const String PROJECT_TAG = "Project";

  /// Session Identifier
  static const String SESSION_TAG = "SessionId";

  /// User Identifier
  static const String USER_ID_TAG = "User_Id";

  /// Usen Name
  static const String USER_NAME_TAG = "User_Name";

  /// User Email
  static const String USER_EMAIL_TAG = "User_Email";

  /// Database Identifier
  static const String DATABASE_ID_TAG = "movil-e";

  /// Global Preferences
  static final Future<SharedPreferences> _context =
      SharedPreferences.getInstance();

  /// Get String Value From Movile Context
  static Future<String?> getStringValue(String key) async {
    Future<String?> value = _context.then((SharedPreferences context) {
      return context.getString(key);
    });
    return value;
  }

  /// Set String Value to Movile Context
  static Future<void> setStringValue(String key, String value) async {
    final SharedPreferences context = await _context;
    context.setString(key, value);
  }

  /// Get Boolean Value From Movile Context
  static Future<bool?> getBooleanValue(String key) async {
    Future<bool?> value = _context.then((SharedPreferences context) {
      return context.getBool(key);
    });
    return value;
  }

  /// Set Boolean Value to Movile Context
  static Future<void> setBooleanValue(String key, bool value) async {
    final SharedPreferences context = await _context;
    context.setBool(key, value);
  }

  /// Get Integer Value From Movile Context
  static Future<int?> getIntegerValue(String key) async {
    Future<int?> value = _context.then((SharedPreferences context) {
      return context.getInt(key);
    });
    return value;
  }

  /// Set Integer Value to Movile Context
  static Future<void> setIntegerValue(String key, int value) async {
    final SharedPreferences context = await _context;
    context.setInt(key, value);
  }

  /// Set EndPoint to Movile Context
  static void setEndPoint(String endPoint) {
    setStringValue(MovileContext.ENDPOINT_TAG, endPoint);
  }

  /// Set Project to Movile Context
  static void setProject(String project) {
    setStringValue(MovileContext.PROJECT_TAG, project);
  }

  /// Set Session Identifier to Movile Context
  static void setSessionId(String sessionId) {
    setStringValue(MovileContext.SESSION_TAG, sessionId);
  }

  /// Get End Point From movile Context
  static Future<String?> getEndPoint() {
    return getStringValue(MovileContext.ENDPOINT_TAG);
  }

  /// Get Project Name From Movile Context
  static Future<String?> getProject() {
    return getStringValue(MovileContext.PROJECT_TAG);
  }

  /// Get Session Identifier Name From Movile Context
  static Future<String?> getSessionId() {
    return getStringValue(MovileContext.SESSION_TAG);
  }

  /// Get User Identifier From Movile Context
  static Future<String?> getUserId() {
    return getStringValue(MovileContext.USER_ID_TAG);
  }

  /// Get User Name From Movile Context
  static Future<String?> getUserName() {
    return getStringValue(MovileContext.USER_NAME_TAG);
  }

  /// Get User Name From Movile Context
  static Future<String?> getUserEmail() {
    return getStringValue(MovileContext.USER_EMAIL_TAG);
  }

  /// Set User Identifier to Movile Context
  static void setUserId(String userId) {
    setStringValue(MovileContext.USER_ID_TAG, userId);
  }

  /// Set User Name to Movile Context
  static void setUserName(String userName) {
    setStringValue(MovileContext.USER_NAME_TAG, userName);
  }

  /// Set User Email to Movile Context
  static void setUserEmail(String userEmail) {
    setStringValue(MovileContext.USER_EMAIL_TAG, userEmail);
  }
}
