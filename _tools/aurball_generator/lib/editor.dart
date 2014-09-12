library editor;

String getPkgBuild(String version, String revision, String md5sum64, String md5sum32) {
  return """
# Maintainer: Claudio d'Angelis <claudiodangelis at gmail dot com>

pkgname=dart-sdk-dev
pkgver=$version
pkgrel=1
pkgdesc="Tools and libraries for Dart development (development channel)"
arch=(i686 x86_64)
url="https://www.dartlang.org/tools/sdk/"
license=('BSD 3-Clause')
provides=('dart-sdk')
conflicts=('dart-sdk' 'dart-editor')
makedepends=('unzip')

if [[ \${CARCH} = x86_64 ]]; then
  source=("https://storage.googleapis.com/dart-archive/channels/dev/release/$revision/sdk/dartsdk-linux-x64-release.zip")
  md5sums=("$md5sum64")
else
  source=("https://storage.googleapis.com/dart-archive/channels/dev/release/$revision/sdk/dartsdk-linux-ia32-release.zip")
  md5sums=("$md5sum32")
fi

package() {

    cd \$pkgdir

    mkdir -p opt/dart-sdk usr/bin usr/share/licenses/dart-sdk
    cp -r \$srcdir/dart-sdk/* opt/dart-sdk

    find . -type f -exec chmod 644 "{}" \;
    find . -type d -exec chmod 755 "{}" \;

    chmod +x opt/dart-sdk/bin/*

    ln -s /opt/dart-sdk/bin/pub            usr/bin/pub
    ln -s /opt/dart-sdk/bin/dart           usr/bin/dart
    ln -s /opt/dart-sdk/bin/docgen         usr/bin/docgen
    ln -s /opt/dart-sdk/bin/dart2js        usr/bin/dart2js
    ln -s /opt/dart-sdk/bin/dartfmt        usr/bin/dartfmt
    ln -s /opt/dart-sdk/bin/dartanalyzer   usr/bin/dartanalyzer

    sed -n '2,4p' opt/dart-sdk/bin/dart2js > usr/share/licenses/dart-sdk/license

}
""";
}