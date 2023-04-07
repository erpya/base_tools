import 'movilecontext.dart';

class LoginUtil {
  static Future<bool> isLoggued() async {
    String? userName = await MovileContext.getUserName();
    return (userName ?? "").isNotEmpty;
  }
}