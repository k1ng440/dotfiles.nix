#!/usr/bin/env bash
set -euo pipefail

# gcm - Git Commit with Opencode
# Auto-stages all modified files (except secrets), generates conventional commit message via opencode

# Secret patterns to exclude from auto-staging
SECRET_PATTERNS=(
  '.env'
  '.envrc'
  '.env.*'
  '*secrets*'
  '*credentials*'
  '*password*'
  '*token*'
  '*key*'
  'sops/*.yaml'
  'sops/*.json'
  '.npmrc'
  '.pypirc'
  '.netrc'
  '*.pem'
  '*.key'
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo -e "${RED}Error: Not in a git repository${NC}"
  exit 1
fi

# Get list of modified files
MODIFIED_FILES=$(git diff --name-only)
STAGED_FILES=$(git diff --cached --name-only)

# Check if there are any changes
if [[ -z "$MODIFIED_FILES" && -z "$STAGED_FILES" ]]; then
  echo -e "${YELLOW}No changes to commit${NC}"
  exit 0
fi

# Function to check if file matches secret patterns
is_secret_file() {
  local file="$1"
  for pattern in "${SECRET_PATTERNS[@]}"; do
    # shellcheck disable=SC2053
    if [[ "$file" == $pattern ]]; then
      return 0
    fi
  done
  return 1
}

# Stage non-secret files
echo -e "${BLUE}Staging files...${NC}"
STAGED_COUNT=0
SKIPPED_COUNT=0

for file in $MODIFIED_FILES; do
  if is_secret_file "$file"; then
    echo -e "  ${YELLOW}⚠ Skipped (secret):${NC} $file"
    ((SKIPPED_COUNT++)) || true
  else
    git add "$file"
    echo -e "  ${GREEN}✓ Staged:${NC} $file"
    ((STAGED_COUNT++)) || true
  fi
done

if [[ $STAGED_COUNT -eq 0 ]]; then
  echo -e "${YELLOW}No files to commit after excluding secrets${NC}"
  exit 0
fi

echo ""
echo -e "${BLUE}Generating commit message with opencode...${NC}"

# Generate commit message via opencode
# opencode will auto-detect the running server
COMMIT_MSG=$(git diff --cached | opencode run "Write a conventional commit message for these changes. Use format: <type>(<scope>): <description>. Types: feat, fix, refactor, docs, style, test, chore. Keep it under 72 characters. Do not include any other text, just the commit message.")

if [[ -z "$COMMIT_MSG" || "$COMMIT_MSG" == "null" ]]; then
  echo -e "${RED}Error: Failed to get commit message from opencode${NC}"
  exit 1
fi

# Show the suggested message
echo ""
echo -e "${GREEN}Suggested commit message:${NC}"
echo "  $COMMIT_MSG"
echo ""

# Ask for confirmation
read -p "Accept (y), Edit (e), or Cancel (n)? [y/e/n] " -n 1 -r
echo ""

case "$REPLY" in
  y|Y)
    git commit -m "$COMMIT_MSG"
    echo -e "${GREEN}✓ Committed!${NC}"
    ;;
  e|E)
    TEMP_FILE=$(mktemp)
    echo "$COMMIT_MSG" > "$TEMP_FILE"
    ${EDITOR:-vi} "$TEMP_FILE"
    FINAL_MSG=$(head -n 1 "$TEMP_FILE")
    rm "$TEMP_FILE"
    if [[ -n "$FINAL_MSG" ]]; then
      git commit -m "$FINAL_MSG"
      echo -e "${GREEN}✓ Committed!${NC}"
    else
      echo -e "${YELLOW}Commit cancelled - empty message${NC}"
      exit 0
    fi
    ;;
  *)
    echo -e "${YELLOW}Commit cancelled${NC}"
    exit 0
    ;;
esac
