import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert' show JSON;

import 'package:aurball_generator/sdk.dart' as sdk;
import 'package:aurball_generator/editor.dart' as editor;

final String USER_HOME = "/home/dawson";
final String VERSION_URI = "http://gsdview.appspot.com/dart-archive/channels/dev/release/latest/VERSION";
final String VERSION_FILE = USER_HOME + "/.dartAurballGenerator";

main() {
  // TODO: use a logger
  // Fetch VERSION
  Map<String, String> version;
  print("Fetching latest version...");
  http.get(VERSION_URI).then((http.Response resp) {
    version = JSON.decode(resp.body);
    print("Latest version: $version");
    if (isNew(version["revision"])) {
      print("Starting the process");
      // Get:
      // - Editor md5sum64
      // - Editor md5sum32
      // - SDK md5sum64
      // - SDK md5sum32
      //
      // TODO: complete
    } else {
      print("Dart is up-to-date");
      // Quit
    }
  });
}

bool isNew(String revision) {
  File f = new File(VERSION_FILE);
  bool exists = f.existsSync();
  return (exists && revision != f.readAsStringSync().trim() || !exists);
}
