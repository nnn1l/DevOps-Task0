#!/usr/bin/env bash


set -e


if [ -z "$REPO_URL" ]; then
  echo "Error: REPO_URL environment variable is not set."
  echo "Please define REPO_URL in your .env file or environment."
  exit 1
fi


BACKUP_DIR="${BACKUP_DIR:-$HOME/backup}"

MAX_BACKUPS=""
MAX_RUNS=1


while [[ $# -gt 0 ]]; do
  case $1 in
    -max-backups)
      MAX_BACKUPS="$2"
      shift 2
      ;;
    -max-runs)
      MAX_RUNS="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

run_backup() {
  TMP_DIR=$(mktemp -d)

  mkdir -p "$BACKUP_DIR"


  git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo"

  VERSIONS_FILE="$BACKUP_DIR/versions.json"


  if [ ! -f "$VERSIONS_FILE" ]; then
    echo "[]" > "$VERSIONS_FILE"
  fi


  LAST_VERSION=$(jq -r '.[-1].version // empty' "$VERSIONS_FILE")

  if [ -z "$LAST_VERSION" ]; then
    NEW_VERSION="1.0.0"
  else
    IFS='.' read -r MAJOR MINOR PATCH <<< "$LAST_VERSION"
    PATCH=$((PATCH + 1))
    if [ "$PATCH" -ge 100 ]; then
      PATCH=0
      MINOR=$((MINOR + 1))
    fi
    NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
  fi

  ARCHIVE_NAME="devops_internship_${NEW_VERSION}"
  ARCHIVE_FILE="${ARCHIVE_NAME}.tar.gz"


  tar -czf "$BACKUP_DIR/$ARCHIVE_FILE" -C "$TMP_DIR/repo" .


  DATE_STR=$(date +"%d.%m.%Y")
  SIZE_BYTES=$(stat -c%s "$BACKUP_DIR/$ARCHIVE_FILE" 2>/dev/null || stat -f%z "$BACKUP_DIR/$ARCHIVE_FILE")


  jq --arg v "$NEW_VERSION" \
     --arg d "$DATE_STR" \
     --argjson s "$SIZE_BYTES" \
     --arg f "$ARCHIVE_NAME" \
     '. + [{"version": $v, "date": $d, "size": $s, "filename": $f}]' \
     "$VERSIONS_FILE" > "$TMP_DIR/versions.json.tmp" && mv "$TMP_DIR/versions.json.tmp" "$VERSIONS_FILE"


  rm -rf "$TMP_DIR"


  if [ -n "$MAX_BACKUPS" ]; then
    if [ "$MAX_BACKUPS" -eq 0 ]; then
      rm -f "$BACKUP_DIR"/*.tar.gz
    else
      ls -1t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -f
    fi
  fi
}

for ((i=1; i<=MAX_RUNS; i++)); do
  echo "Running backup iteration $i of $MAX_RUNS..."
  run_backup
done