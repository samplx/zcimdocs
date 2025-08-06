#!/bin/bash

# unpacks the Typst.app zip of the project into the github structure.

# usage: ./unpack.sh

SOURCE_ZIP="$HOME/Downloads/zcimdocs.zip"

WORKING="$(mktemp -d)"
TARGET="$(pwd)"

[ -d "$WORKING" ] || mkdir -p "$WORKING"
cd "$WORKING" || exit 86
unzip "$SOURCE_ZIP"

rsync -av asm bdos-common.typ cbasic cpm13 cpm14 cpm20 cpm22 cpm30 ddt ed link80 mac80 pascal pli80 sid tex zcim zcim-library.typ "$TARGET"/

cd "$TARGET" || exit 86

# timestamps are fubar, so mark everything up-to-date after unpacking
find . -maxdepth 2 -name '*.typ' -exec touch --no-create '{}' \;

rm -rf "$WORKING"

