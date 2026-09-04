#!/bin/sh
# Build the tree-sitter grammars that Helix does not ship itself.
#
# `hx --grammar fetch` would clone all ~245 grammars in Helix's default
# languages.toml, so the handful we add ourselves are built directly instead.
# The compiled .so files land in runtime/grammars/ and are gitignored.
#
# Keep REV in sync with the `rev` of the matching [[grammar]] entries in
# languages.toml.

set -eu

REPO="https://github.com/WardBrian/tree-sitter-stan"
REV="74d7eb2d970c84982c8c687a20695ebe2f259cfd" # v0.3.1
GRAMMARS="stan stanfunctions"

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
out="$here/runtime/grammars"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

mkdir -p "$out"

echo "Fetching $REPO @ $REV"
git clone --quiet --filter=blob:none "$REPO" "$work/src"
git -C "$work/src" checkout --quiet "$REV"

for g in $GRAMMARS; do
    echo "Building $g.so"
    "${CC:-cc}" -shared -fPIC -fno-exceptions -O2 \
        -I "$work/src/grammars/$g/src" \
        -o "$out/$g.so" \
        "$work/src/grammars/$g/src"/*.c
done

echo "Done. Verify with: hx --health stan"
