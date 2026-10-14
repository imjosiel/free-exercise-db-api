#!/usr/bin/env bash
set -euo pipefail

# Import the original exercise image folders from yuhonas/free-exercise-db.
# Images are copied into this repository so the app does not depend on the
# upstream repository being available at runtime.

SOURCE_REPO="https://github.com/yuhonas/free-exercise-db.git"
SOURCE_REF="${SOURCE_REF:-main}"
DEST_DIR="assets/original-exercise-images"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Cloning upstream dataset ($SOURCE_REF)..."
git clone --depth 1 --branch "$SOURCE_REF" "$SOURCE_REPO" "$TMP_DIR/upstream"

mkdir -p "$DEST_DIR"

# Keep only exercise image directories (e.g. Air_Bike/0.jpg and 1.jpg),
# not the upstream JSON files, because this repository has its own data model.
count=0
while IFS= read -r -d '' dir; do
  name="$(basename "$dir")"
  if find "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print -quit | grep -q .; then
    rm -rf "$DEST_DIR/$name"
    cp -R "$dir" "$DEST_DIR/$name"
    count=$((count + 1))
  fi
done < <(find "$TMP_DIR/upstream/exercises" -mindepth 1 -maxdepth 1 -type d -print0)

if [ "$count" -eq 0 ]; then
  echo "ERROR: no exercise image folders were found in upstream repository." >&2
  exit 1
fi

echo "Imported $count exercise image folders into $DEST_DIR"
echo "Image files: $(find "$DEST_DIR" -type f | wc -l | tr -d ' ')"
