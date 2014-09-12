import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert' show JSON;

import 'package:aurball_generator/sdk.dart' as sdk;
import 'package:aurball_generator/editor.dart' as editor;

import 'package:html5lib/parser.dart' show parse;
import 'package:html5lib/dom.dart';

final String USER_HOME = "/home/dawson";
final String VERSION_URI =
    "http://gsdview.appspot.com/dart-archive/channels/dev/release/latest/VERSION";
final String VERSION_FILE = USER_HOME + "/.dartAurballGenerator";

final String EDITOR_URI =
    "http://gsdview.appspot.com/dart-archive/channels/dev/release/latest/editor/";
final String SDK_URI =
    "http://gsdview.appspot.com/dart-archive/channels/dev/release/latest/sdk/";

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
      // Editor data:
      http.get(EDITOR_URI).then((http.Response resp) {
        String md5sum32;
        String md5sum64;
        Document editorHtml = parse(resp.body);
        List<Element> anchors = editorHtml.querySelectorAll('html a');
        anchors.forEach((elem) {
          switch (elem.text) {
            case "darteditor-linux-ia32.zip":
              // - Editor md5sum32
              md5sum32 =
                  elem.parent.parent.children[3].text.replaceAll('"', "");
              break;

            case "darteditor-linux-x64.zip":
              // - Editor md5sum64
              md5sum64 =
                  elem.parent.parent.children[3].text.replaceAll('"', "");
              break;
          }
        });

        makeAurball('editor', editor.getPkgBuild(version["version"],
          version["revision"], md5sum64,md5sum32), '/tmp', 'darteditor');

      });

      // SDK data
      http.get(SDK_URI).then((http.Response resp) {
        String md5sum32;
        String md5sum64;
        Document editorHtml = parse(resp.body);
        List<Element> anchors = editorHtml.querySelectorAll('html a');
        anchors.forEach((elem) {
          switch (elem.text) {
            case "dartsdk-linux-ia32-release.zip":
              // - SDK md5sum32
              md5sum32 =
                  elem.parent.parent.children[3].text.replaceAll('"', "");
              break;

            case "dartsdk-linux-x64-release.zip":
              // - SDK md5sum64
              md5sum64 =
                  elem.parent.parent.children[3].text.replaceAll('"', "");
              break;
          }
        });

        makeAurball('sdk', sdk.getPkgBuild(version["version"],
          version["revision"], md5sum64,md5sum32), '/tmp', 'dartsdk');

      });
      new File(VERSION_FILE).writeAsStringSync(version["revision"]);
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

void makeAurball(String pkgname, String pkgbuild, String path, String zipFilePrefix) {
  print("Making aurball for $pkgname in $path");
  String pkgbuildPath = path + "/PKGBUILD_" + pkgname;
  File f = new File(pkgbuildPath);
  f.writeAsStringSync(pkgbuild);

  // FIXME ASAP: the actual tarball is generated in the cwd, not cool
  Process.run('mkaurball', ['-p', pkgbuildPath]).then((_) {
    f.deleteSync();
    // TODO: find a more elegant way to do this
    Process.run('bash', ['-c', 'rm  $zipFilePrefix*.zip']).then((_) {
      print("Completed making aurball for $pkgname");
    });
  });
}
