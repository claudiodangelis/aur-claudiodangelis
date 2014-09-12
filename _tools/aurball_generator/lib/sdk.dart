library sdk;

String getPkgBuild(String version, String revision, String md5sum64, String md5sum32) {
  return """
# Maintainer : Claudio d'Angelis <claudiodangelis at gmail dot com>

pkgname=dart-editor-dev
_pkgname=DartEditor
pkgver=$version
pkgrel=1
pkgdesc="Editor and tools for the Dart programming language."
arch=(i686 x86_64)
url="http://www.dartlang.org/docs/editor/getting-started"
license=(EPL)
conflicts=('dart-editor')
provides=('dart-editor')


depends=('java-runtime>=6' 'gtk2' 'desktop-file-utils' 'gconf' 'libudev.so.0' 'libgcrypt15')
makedepends=('unzip')
backup=(opt/dart-editor/\${_pkgname}.ini)

if [[ \${CARCH} = x86_64 ]]; then
    source=("https://storage.googleapis.com/dart-archive/channels/dev/release/$revision/editor/darteditor-linux-x64.zip")
    md5sums=("$md5sum64")
else
    source=("https://storage.googleapis.com/dart-archive/channels/dev/release/$revision/editor/darteditor-linux-ia32.zip")
    md5sums=("$md5sum32")
fi

build() {
  msg2 "Generate desktop application entry..."
  cat > "\${srcdir}"/dart-editor.desktop << EOF
[Desktop Entry]
Version=\${pkgver}
Encoding=UTF-8
Name=Dart editor
Comment=\${pkgdesc}
Exec=/usr/bin/dart-editor
Icon=/opt/dart-editor/icon.xpm
Terminal=false
Type=Application
Categories=Development;
EOF
}

package() {
  msg2 "Install the assembly at /opt/dart-editor..."
  install -dm755           "\${pkgdir}"/opt/dart-editor
  cp -a "\${srcdir}"/dart/* "\${pkgdir}"/opt/dart-editor

  msg2 "Fix permissions"
  chmod -R +r "\${pkgdir}"/opt/dart-editor
  chmod -R +r "\${pkgdir}"/opt/dart-editor/dart-sdk
  chmod -R +r "\${pkgdir}"/opt/dart-editor/chromium
  chmod +x "\${pkgdir}"/opt/dart-editor/dart-sdk/bin/*

  msg2 "Install links to the executables in /usr/bin..."
  install -dm755                    "\${pkgdir}"/usr/bin
  ln -s /opt/dart-editor/\${_pkgname} "\${pkgdir}"/usr/bin/dart-editor
  ln -s /opt/dart-editor/\${_pkgname} "\${pkgdir}"/usr/bin/\${_pkgname}

  msg2 "Install links to the documentation resources in /usr/share/doc/dart-editor..."
  install -dm755                    "\${pkgdir}"/usr/share/doc/dart-editor
  ln -s /opt/dart-editor/samples     "\${pkgdir}"/usr/share/doc/dart-editor/
  ln -s /opt/dart-editor/about.html  "\${pkgdir}"/usr/share/doc/dart-editor/
  ln -s /opt/dart-editor/about_files "\${pkgdir}"/usr/share/doc/dart-editor/

  msg2 "Install link to the config file in /etc..."
  install -dm755                        "\${pkgdir}"/etc
  ln -s /opt/dart-editor/\${_pkgname}.ini "\${pkgdir}"/etc/dart-editor.ini

  msg2 "Install desktop application entry in /usr/share/applications..."
  install -Dm644 "\${srcdir}"/dart-editor.desktop "\${pkgdir}"/usr/share/applications/dart-editor.desktop

  msg2 "Linking binaries"
  cd \$pkgdir

  mkdir -p opt/dart-editor/dart-sdk/bin usr/bin
  chmod +x opt/dart-editor/dart-sdk/bin/*
  ln -s /opt/dart-editor/dart-sdk/bin/pub            usr/bin/pub
  ln -s /opt/dart-editor/dart-sdk/bin/dart           usr/bin/dart
  ln -s /opt/dart-editor/dart-sdk/bin/docgen         usr/bin/docgen
  ln -s /opt/dart-editor/dart-sdk/bin/dart2js        usr/bin/dart2js
  ln -s /opt/dart-editor/dart-sdk/bin/dartfmt        usr/bin/dartfmt
  ln -s /opt/dart-editor/dart-sdk/bin/dartanalyzer   usr/bin/dartanalyzer

}

""";
}