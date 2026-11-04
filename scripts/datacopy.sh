#!/bin/sh

## Custom datacopy.sh to overwrite upstream's 
## so we can include tilesets, etc.

DATA_SRC="$(cd "$(dirname "$0")/../../" || exit 1 ; pwd)"
DATA_TGT="$(pwd)"

mkdir -p "${DATA_TGT}/data/themes" || exit 1

# Existing Freeciv resources
cp "${DATA_SRC}/data/helpdata.txt" "${DATA_TGT}/data/" || exit 1
cp -R "${DATA_SRC}/data/themes/gui-sdl2" \
      "${DATA_TGT}/data/themes/" || exit 1

# Default map tileset: Hexemplio
cp "${DATA_SRC}/data/hexemplio.tilespec" \
   "${DATA_TGT}/data/" || exit 1

cp -R "${DATA_SRC}/data/hexemplio" \
      "${DATA_TGT}/data/" || exit 1

# Shared graphics resources referenced by Hexemplio
cp -R "${DATA_SRC}/data/amplio2" \
      "${DATA_TGT}/data/" || exit 1

cp -R "${DATA_SRC}/data/misc" \
      "${DATA_TGT}/data/" || exit 1

echo "data copied successfully."
