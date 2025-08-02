#!/bin/bash

# unpacks the Typst.app zip of the project into the github structure.

# usage: ./unpack.sh

SOURCE_ZIP="$HOME/Downloads/zcimdocs.zip"

WORKING="$(mktemp -d)"
TARGET="$(pwd)"

[ -d "$WORKING" ] || mkdir -p "$WORKING"
cd "$WORKING"
unzip "$SOURCE_ZIP"

rsync -av asm cbasic cpm* ddt ed link80 mac80 pascal pli80 sid tex zcim* "$TARGET"/

cd "$TARGET" || exit 86

rm -rf "$WORKING"

