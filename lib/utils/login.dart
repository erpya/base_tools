import 'movilecontext.dart';

class LoginUtil {
  static bool isLoggued() {
    String? userName = MovileContext.getUserName();
    return (userName ?? "").isNotEmpty;
  }
}
