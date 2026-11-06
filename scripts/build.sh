
#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

WORK="$PWD/work"
SRC="$WORK/freeciv"
EMSDK="$WORK/emsdk"
BUILD="$WORK/build"
NATIVE="$WORK/native"

rm -rf "$WORK" public
mkdir -p "$WORK" "$BUILD"

# Get Freeciv
git clone --depth 1 https://github.com/freeciv/freeciv.git "$SRC"


# Overwrite upstream datacopy.sh to include more stuff

cp "$ROOT/scripts/datacopy.sh" \
   "$SRC/platforms/emscripten/datacopy.sh"

chmod +x "$SRC/platforms/emscripten/datacopy.sh"

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

# Build Freeciv
############### -- yoinked from em

# Install Emscripten SDK
"$SRC/platforms/emscripten/emssetup.sh" "$EMSDK"

# Load Emscripten environment
EMSDK_ROOT="$(cd "$EMSDK" && pwd)"
cd "$EMSDK_ROOT"
source ./emsdk_env.sh

# Configure build paths
PLATFORM_ROOT="$SRC/platforms/emscripten"

cd "$BUILD"

# Generate Emscripten cross-file
sed "s,<EMSDK_ROOT>,${EMSDK_ROOT},g" \
    "$PLATFORM_ROOT/setups/cross-ems.tmpl" > cross.txt

# Build SDL dependencies
embuilder build sdl2 sdl2_image sdl2_ttf

# Configure Freeciv
meson setup \
    --cross-file=cross.txt \
    -Ddefault_library=static \
    -Ddebug=true \
    -Daudio=none \
    -Dmwand=false \
    -Dtools=[] \
    -Dclients=sdl2 \
    -Dserver=enabled \
    -Ddynaimod=false \
    -Daimodules=classic \
    -Dfcmp=[] \
    -Dfcdb=[] \
    "$SRC"

# Build
ninja

##############


# Collect browser files
mkdir -p "$OLDPWD/public"

# Build outputs freeciv-sdl2.html.p directory - I think we can ignore it - find to grab just the files
find . -maxdepth 1 -type f -name 'freeciv-sdl2.*' \
    -exec cp {} "$OLDPWD/public/" \;

# Install coi-serviceworker - so pthreads works or something
curl -fsSL \
    https://raw.githubusercontent.com/gzuidhof/coi-serviceworker/master/coi-serviceworker.min.js \
    -o "$OLDPWD/public/coi-serviceworker.min.js"

# GitHub Pages entry point
cp "$ROOT/index.html" "$OLDPWD/public/index.html"

touch "$OLDPWD/public/.nojekyll"
