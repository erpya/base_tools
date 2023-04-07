abstract class ApiDocument<T> {
  String? getId();
  ApiDocument();
  fromJSON(Map<String, dynamic> json);
  Map<String, dynamic> toJSON();
  T copy();
}
