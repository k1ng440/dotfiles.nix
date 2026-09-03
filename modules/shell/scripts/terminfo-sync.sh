#!/usr/bin/env bash
set -euo pipefail

# Push local $TERM terminfo to SSH hosts so remote recognizes the terminal
# Usage: terminfo-sync [host1 host2 ...]

TERM_ENTRY="${TERM:-xterm-256color}"

# Verify local terminfo exists before attempting to push
if ! infocmp -x "$TERM_ENTRY" &>/dev/null; then
  echo "No local terminfo found for '$TERM_ENTRY', falling back to xterm-256color"
  TERM_ENTRY="xterm-256color"
fi

push_terminfo() {
  local host="$1"
  echo -n "  $host ($TERM_ENTRY) ... "
  if infocmp -x "$TERM_ENTRY" | ssh "$host" -- tic -x - 2>/dev/null; then
    echo "ok"
  else
    echo "FAILED"
    return 1
  fi
}

GIT_HOSTS="github.com gitlab.com bitbucket.org git.sr.ht"

get_ssh_hosts() {
  grep "^Host " ~/.ssh/config \
    | awk '{for(i=2;i<=NF;i++) print $i}' \
    | grep -v '\*' \
    | while read -r h; do
        skip=0
        for g in $GIT_HOSTS; do
          [[ "$h" == "$g" ]] && skip=1 && break
        done
        [[ $skip -eq 0 ]] && echo "$h"
      done
}

if [[ $# -gt 0 ]]; then
  HOSTS=("$@")
else
  mapfile -t HOSTS < <(get_ssh_hosts)
fi

if [[ ${#HOSTS[@]} -eq 0 ]]; then
  echo "No SSH hosts found in ~/.ssh/config"
  exit 1
fi

echo "Syncing '$TERM_ENTRY' terminfo to ${#HOSTS[@]} host(s):"
FAILED=0
for host in "${HOSTS[@]}"; do
  push_terminfo "$host" || ((FAILED++)) || true
done

if [[ $FAILED -gt 0 ]]; then
  echo "$FAILED host(s) failed"
  exit 1
fi
echo "Done."
