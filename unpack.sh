#!/bin/bash

# unpacks the Typst.app zip of the project into the github structure.

# usage: ./unpack.sh

SOURCE_ZIP="$HOME/Downloads/zcimdocs.zip"

WORKING="$(mktemp -d)"
TARGET="$(pwd)"

[ -d "$WORKING" ] || mkdir -p "$WORKING"
cd "$WORKING"
unzip "$SOURCE_ZIP"

if [ -f "link80-manual.typ" ]
then
    rm -f "$TARGET/link80/link80-manual.typ"
    mv -v "link80-manual.typ" "$TARGET/link80/link80-manual.typ"
fi

if [ -f "mac80-manual.typ" ]
then
    rm -f "$TARGET/mac80/mac80-manual.typ"
    mv -v "mac80-manual.typ" "$TARGET/mac80/mac80-manual.typ"
fi

if [ -f "cpm22-manual.typ" ]
then
    rm -f "$TARGET/cpm22/cpm22-manual.typ"
    mv -v "cpm22-manual.typ" "$TARGET/cpm22/cpm22-manual.typ"
fi


cd "$TARGET" || exit 86

rm -rf "$WORKING"

