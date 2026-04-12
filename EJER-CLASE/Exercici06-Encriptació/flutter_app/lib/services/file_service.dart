import 'package:file_picker/file_picker.dart';

class FileService {

  Future<String?> pickFile() async {

    final result = await FilePicker.platform.pickFiles();

    if (result == null) return null;

    return result.files.single.path;
  }
}