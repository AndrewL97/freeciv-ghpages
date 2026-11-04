
#!/usr/bin/env bash
set -e

WORK="$PWD/work"
SRC="$WORK/freeciv"
EMSDK="$WORK/emsdk"
BUILD="$WORK/build"
NATIVE="$WORK/native"

rm -rf "$WORK" public
mkdir -p "$WORK" "$BUILD"

# Get Freeciv
git clone --depth 1 https://github.com/freeciv/freeciv.git "$SRC"

# Build native tolua (something about freeciv or something something)
meson setup "$NATIVE" "$SRC" \
    -Dclients=[] \
    -Dserver=disabled \
    -Dtools=[] \
    -Dfcmp=[] \
    -Dfcdb=[] \
    -Daudio=none \
    -Dnls=false \
    -Dmwand=false \
    -Dsyslua=false

ninja -C "$NATIVE" tolua

# Make native tolua available to the Emscripten build
export PATH="$NATIVE:$PATH"

# Install Emscripten SDK (version is defined by upstream script)
"$SRC/platforms/emscripten/emssetup.sh" "$EMSDK"

# Build Freeciv
cd "$BUILD"
"$SRC/platforms/emscripten/emsbuild.sh" "$EMSDK"

# Collect browser files
mkdir -p "$OLDPWD/public"
cp freeciv-sdl2.* "$OLDPWD/public/"

# GitHub Pages entry point
cp "$OLDPWD/public/freeciv-sdl2.html" "$OLDPWD/public/index.html"
touch "$OLDPWD/public/.nojekyll"
