#!/usr/bin/env bash
# No UID - Standalone cleanup script for CI/CD or manual use
# Usage: ./clean_uids.sh [project_path]
# Defaults to current directory if no path provided

set -euo pipefail

PROJECT_PATH="${1:-.}"
DELETED=0
STRIPPED=0

echo "[NoUID] Cleaning UIDs in: $PROJECT_PATH"

# Pass 1: Delete all .uid files
while IFS= read -r -d '' file; do
    rm -f "$file"
    ((DELETED++)) || true
done < <(find "$PROJECT_PATH" -name "*.uid" -type f -print0 2>/dev/null)

# Pass 2: Strip UIDs from scenes and resources
strip_uids() {
    local file="$1"
    local tmp="${file}.tmp"
    
    # Use perl for consistent regex across platforms
    if perl -pe 's/(^|\s)uid="uid:\/\/[a-z0-9]+"//g' < "$file" > "$tmp"; then
        if ! cmp -s "$file" "$tmp"; then
            mv "$tmp" "$file"
            ((STRIPPED++)) || true
        else
            rm -f "$tmp"
        fi
    else
        rm -f "$tmp"
    fi
}

export -f strip_uids
export STRIPPED

# Find all relevant files: .tscn, .tres
while IFS= read -r -d '' file; do
    strip_uids "$file"
done < <(find "$PROJECT_PATH" \( -name "*.tscn" -o -name "*.tres" \) -type f -print0 2>/dev/null)

# Pass 3: Warn about UID refs in scripts
WARNINGS=0
while IFS= read -r -d '' file; do
    matches=$(grep -c 'uid://' "$file" 2>/dev/null || true)
    if [ "$matches" -gt 0 ]; then
        echo "[NoUID] WARNING: $file contains $matches UID reference(s)"
        ((WARNINGS+=matches)) || true
    fi
done < <(find "$PROJECT_PATH" -name "*.gd" -type f -print0 2>/dev/null)

echo "[NoUID] Done: $DELETED .uid files deleted, $STRIPPED resources cleaned"
[ "$WARNINGS" -gt 0 ] && echo "[NoUID] $WARNINGS UID references found in scripts - fix manually"

exit 0
