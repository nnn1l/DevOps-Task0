#!/usr/bin/env bash
set -e

MAX_BACKUPS=""
MAX_RUNS=1
BACKUP_DIR="${BACKUP_DIR:-$HOME/backup}"
REPO_URL="${REPO_URL:-}"

is_integer() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

# --- Parse CLI Arguments ---
while [[ $# -gt 0 ]]; do
  case $1 in
    -max-backups)
      if ! is_integer "$2"; then
        echo "Error: -max-backups requires a non-negative integer argument."
        exit 1
      fi
      MAX_BACKUPS="$2"
      shift 2
      ;;
    -max-runs)
      if ! is_integer "$2" || [ "$2" -le 0 ]; then
        echo "Error: -max-runs requires a positive integer argument."
        exit 1
      fi
      MAX_RUNS="$2"
      shift 2
      ;;
    *)
      echo "Error: Unknown argument $1"
      exit 1
      ;;
  esac
done

if [ -z "$REPO_URL" ]; then
  echo "Error: REPO_URL environment variable is required."
  exit 1
fi

mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null

mkdir -p "$BACKUP_DIR"
VERSIONS_FILE="$BACKUP_DIR/versions.json"

if [ ! -f "$VERSIONS_FILE" ]; then
  echo "[]" > "$VERSIONS_FILE"
fi

get_next_version() {
  local last_version
  last_version=$(jq -r '.[-1].version // empty' "$VERSIONS_FILE")

  if [ -z "$last_version" ] || [ "$last_version" == "null" ]; then
    echo "1.0.0"
    return
  fi

  IFS='.' read -r major minor patch <<< "$last_version"
  patch=$((patch + 1))

  if [ "$patch" -ge 100 ]; then
    patch=0
    minor=$((minor + 1))
  fi

  echo "${major}.${minor}.${patch}"
}

manage_old_backups() {
  if [ -n "$MAX_BACKUPS" ]; then
    if [ "$MAX_BACKUPS" -eq 0 ]; then
      echo "Removing all backup archives (-max-backups 0)..."
      rm -f "$BACKUP_DIR"/*.tar.gz 2>/dev/null || true
    else
      echo "Cleaning up old backups. Keeping last $MAX_BACKUPS files..."
      mapfile -t files < <(ls -1t "$BACKUP_DIR"/*.tar.gz 2>/dev/null || true)
      if [ "${#files[@]}" -gt "$MAX_BACKUPS" ]; then
        for ((i=MAX_BACKUPS; i<${#files[@]}; i++)); do
          rm -f "${files[$i]}"
        done
      fi
    fi
  fi
}

run_backup() {
  local version
  version=$(get_next_version)
  local filename="devops_internship_${version}"
  local temp_dir
  temp_dir=$(mktemp -d)

  trap 'rm -rf "$temp_dir"' EXIT

  echo "Cloning repository into temporary directory..."
  git clone "$REPO_URL" "$temp_dir/repo" --quiet

  echo "Creating archive ${filename}.tar.gz..."
  tar -czf "$BACKUP_DIR/${filename}.tar.gz" -C "$temp_dir/repo" .

  local file_size
  file_size=$(stat -c%s "$BACKUP_DIR/${filename}.tar.gz" 2>/dev/null || stat -f%z "$BACKUP_DIR/${filename}.tar.gz")
  local current_date
  current_date=$(date +"%d.%m.%Y")

  jq --arg v "$version" \
     --arg d "$current_date" \
     --argjson s "$file_size" \
     --arg f "$filename" \
     '. += [{"version": $v, "date": $d, "size": $s, "filename": $f}]' \
     "$VERSIONS_FILE" > "$VERSIONS_FILE.tmp" && mv "$VERSIONS_FILE.tmp" "$VERSIONS_FILE"

  echo "Backup $filename created successfully!"

  rm -rf "$temp_dir"
  trap - EXIT

  manage_old_backups
}

for ((run=1; run<=MAX_RUNS; run++)); do
  echo "Running backup iteration $run of $MAX_RUNS..."
  run_backup
done