#!/bin/bash

mkdir -p build
[ ! -f build/.gdignore ] && touch build/.gdignore
godot --headless --export-release "WebGL" build/index.html
mkdir -p build/game
cp -r build/* build/game/
rm -rf build/game/game
sed -i '' 's/<meta charset="utf-8">/<base href="\/game\/" \/>\n<meta charset="utf-8">/' build/index.html