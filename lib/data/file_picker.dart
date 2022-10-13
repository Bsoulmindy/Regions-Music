import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../domain/alert_exception.dart';

Future<File?> fileAudioPick() async {
  // Lets the user pick one file;
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.audio);

  if (result != null && result.files.first.path != null) {
    String path = result.files.first.path ?? "";
    File file = File(path);

    return file;
  } else if (result != null && result.files.first.path == null) {
    throw AlertException("Couldn't get the path of this file");
  }

  return null;
}

Future<File?> fileTextPick() async {
  // Lets the user pick one file;
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: ['txt']);

  if (result != null && result.files.first.path != null) {
    String path = result.files.first.path ?? "";
    File file = File(path);

    return file;
  } else if (result != null && result.files.first.path == null) {
    throw AlertException("Couldn't get the path of this file");
  }

  return null;
}

Future<File?> fileImagePick() async {
  // Lets the user pick one file;
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null && result.files.first.path != null) {
    String path = result.files.first.path ?? "";
    File file = File(path);

    return file;
  } else if (result != null && result.files.first.path == null) {
    throw AlertException("Couldn't get the path of this file");
  }

  return null;
}
