#!/bin/bash
# sync-claude-md.sh
#
# Sync CLAUDE.md from this template-workflow-base repo to target projects.
# Preserves project-specific sections written BELOW the marker:
#
#   <!-- TEMPLATE_END — 项目特有 sections 写在下面，sync script 不会覆盖下方内容 -->
#
# Usage:
#   ./scripts/sync-claude-md.sh                       # sync to all known projects
#   ./scripts/sync-claude-md.sh <proj> [<proj>...]    # sync to specific projects
#   ./scripts/sync-claude-md.sh --dry-run [<proj>]    # show diff without writing
#
# Project paths are resolved under $HOME/WorkSpace/<proj>.
#
# Safety:
# - Each project CLAUDE.md is backed up to /tmp before write
# - Dry-run mode shows diff without touching anything
# - Never git-commits automatically (caller does that)
# - Requires the marker to already exist in target project's CLAUDE.md;
#   refuses to overwrite if marker is missing (first-time setup must be manual)

set -euo pipefail

MARKER="<!-- TEMPLATE_END — 项目特有 sections 写在下面，sync script 不会覆盖下方内容 -->"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TEMPLATE_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
TEMPLATE_FILE="$TEMPLATE_DIR/CLAUDE.md"

# Default project list (can be overridden by positional args)
DEFAULT_PROJECTS=(
  "ak-ai-vela"
  "ak-fund-advisor"
  "ai-blogger-lab"
  "ak-ai-postflow"
  "ak-wallpaper-pipeline"
)

DRY_RUN=false
PROJECTS=()

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help|-h)
      head -20 "$0" | sed 's/^# //; s/^#//'
      exit 0
      ;;
    *)
      PROJECTS+=("$1")
      shift
      ;;
  esac
done

# If no projects specified, use defaults
if [ ${#PROJECTS[@]} -eq 0 ]; then
  PROJECTS=("${DEFAULT_PROJECTS[@]}")
fi

# Sanity: template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "ERROR: template not found at $TEMPLATE_FILE" >&2
  exit 1
fi

# Sanity: template has the marker
if ! grep -qF "$MARKER" "$TEMPLATE_FILE"; then
  echo "ERROR: template $TEMPLATE_FILE does not contain the TEMPLATE_END marker." >&2
  echo "       Add this line to the end of the template:" >&2
  echo "       $MARKER" >&2
  exit 1
fi

# Extract template body (everything UP TO AND INCLUDING the marker)
TEMPLATE_BODY=$(awk -v m="$MARKER" '
  { print }
  index($0, m) { exit }
' "$TEMPLATE_FILE")

echo "Template: $TEMPLATE_FILE"
echo "Template body lines (up to marker): $(echo "$TEMPLATE_BODY" | wc -l | tr -d ' ')"
echo ""

FAILED=()

for proj in "${PROJECTS[@]}"; do
  TARGET="$HOME/WorkSpace/$proj/CLAUDE.md"

  if [ ! -f "$TARGET" ]; then
    echo "  ✗ $proj: CLAUDE.md not found at $TARGET — SKIPPED"
    FAILED+=("$proj (file missing)")
    continue
  fi

  # Check target has the marker
  if ! grep -qF "$MARKER" "$TARGET"; then
    echo "  ✗ $proj: missing TEMPLATE_END marker — SKIPPED"
    echo "      First-time setup: manually add marker + move project-specific"
    echo "      sections below it, then re-run this script."
    FAILED+=("$proj (no marker)")
    continue
  fi

  # Extract project-specific portion (everything AFTER the marker)
  PROJECT_SPECIFIC=$(awk -v m="$MARKER" '
    BEGIN { found = 0 }
    { if (found) print }
    index($0, m) { found = 1 }
  ' "$TARGET")

  # Build new content
  NEW_CONTENT="$TEMPLATE_BODY"$'\n'"$PROJECT_SPECIFIC"

  if $DRY_RUN; then
    echo "  [dry-run] $proj:"
    echo "    current  lines: $(wc -l < "$TARGET" | tr -d ' ')"
    echo "    would be lines: $(echo "$NEW_CONTENT" | wc -l | tr -d ' ')"
    # Show diff summary
    diff <(echo "$NEW_CONTENT") "$TARGET" > /tmp/sync-diff-$proj.txt 2>/dev/null || true
    if [ -s /tmp/sync-diff-$proj.txt ]; then
      echo "    diff lines: $(wc -l < /tmp/sync-diff-$proj.txt | tr -d ' ')"
      echo "    (see /tmp/sync-diff-$proj.txt for full diff)"
    else
      echo "    no changes"
    fi
    continue
  fi

  # Backup
  BACKUP="/tmp/claude-md-backup-$proj-$(date +%s).md"
  cp "$TARGET" "$BACKUP"

  # Write new content
  printf '%s\n' "$NEW_CONTENT" > "$TARGET"

  # Verify the write succeeded and file is not empty
  if [ ! -s "$TARGET" ]; then
    echo "  ✗ $proj: write produced empty file — RESTORING from backup"
    cp "$BACKUP" "$TARGET"
    FAILED+=("$proj (empty write)")
    continue
  fi

  echo "  ✓ $proj: synced ($(wc -l < "$TARGET" | tr -d ' ') lines, backup at $BACKUP)"
done

echo ""
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "Failures:"
  for f in "${FAILED[@]}"; do
    echo "  - $f"
  done
  exit 1
fi

echo "All targets synced successfully."
echo ""
echo "Next: review each project's git diff and commit separately."
echo "  cd ~/WorkSpace/<project>"
echo "  git diff CLAUDE.md"
echo "  git add CLAUDE.md && git commit -m \"docs(CLAUDE.md): sync from template-workflow-base\""
