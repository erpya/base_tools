import 'package:appwrite/appwrite.dart' as appwrite;

class Databases extends appwrite.Databases {
  String id;
  Databases(super.client, this.id);
}
