#!/usr/bin/env bash
# sync-rules.sh
# Copies Cursor rules from escritha-skills to each repo.
# Run this script from the root of the escritha-skills repo.
#
# Usage:
#   ./sync-rules.sh
#
# Expected sibling folder layout:
#   ../escritha-api/
#   ../escritha-app/
#   ../escritha-book/
#   ../escritha-skills/   ← you are here

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_DIR="$SCRIPT_DIR/cursor"

API_DIR="$SCRIPT_DIR/../escritha-api"
APP_DIR="$SCRIPT_DIR/../escritha-app"
BOOK_DIR="$SCRIPT_DIR/../escritha-book"

echo "🔄  Syncing Cursor rules from escritha-skills..."

# ── escritha-api ──────────────────────────────────────────────────────────────
if [ -d "$API_DIR" ]; then
  mkdir -p "$API_DIR/.cursor/rules"
  cp "$CURSOR_DIR/api.mdc" "$API_DIR/.cursor/rules/escritha-standards.mdc"
  echo "✅  escritha-api  →  .cursor/rules/escritha-standards.mdc"
else
  echo "⚠️   escritha-api not found at $API_DIR — skipped"
fi

# ── escritha-app ──────────────────────────────────────────────────────────────
if [ -d "$APP_DIR" ]; then
  mkdir -p "$APP_DIR/.cursor/rules"
  cp "$CURSOR_DIR/app.mdc" "$APP_DIR/.cursor/rules/escritha-standards.mdc"
  echo "✅  escritha-app  →  .cursor/rules/escritha-standards.mdc"
else
  echo "⚠️   escritha-app not found at $APP_DIR — skipped"
fi

# ── escritha-book ─────────────────────────────────────────────────────────────
if [ -d "$BOOK_DIR" ]; then
  mkdir -p "$BOOK_DIR/.cursor/rules"
  cp "$CURSOR_DIR/book.mdc" "$BOOK_DIR/.cursor/rules/escritha-standards.mdc"
  echo "✅  escritha-book →  .cursor/rules/escritha-standards.mdc"
else
  echo "⚠️   escritha-book not found at $BOOK_DIR — skipped"
fi

echo ""
echo "🎉  Done! Commit the .cursor/rules/ folder in each repo to version-control the rules."