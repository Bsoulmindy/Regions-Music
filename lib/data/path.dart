import 'package:path_provider/path_provider.dart';

Future<String> getLocalPath() async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}
