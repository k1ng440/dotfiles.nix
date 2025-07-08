#!/usr/bin/env sh
set -e

REPO_URL="https://github.com/k1ng440/dotfiles.nix.git"
BRANCH="master"
DEST_DIR="/home/nixos/nix/nix-config"

command -v git >/dev/null 2>&1 || {
  echo "Error: git not found"
  exit 1
}
ping -c 1 github.com >/dev/null 2>&1 || {
  echo "Error: No network connection"
  exit 1
}
git config --global init.defaultBranch master

mkdir -p "$DEST_DIR"

if [ -d "$DEST_DIR/.git" ]; then
  echo "Updating existing configuration in $DEST_DIR..."
  cd "$DEST_DIR"
  git fetch origin "$BRANCH" --depth 1
  git checkout "origin/$BRANCH"
else
  echo "Cloning configuration from $REPO_URL to $DEST_DIR..."
  cd "$DEST_DIR"
  git init
  git remote add origin "$REPO_URL"
  git fetch origin "$BRANCH" --depth 1
  git checkout "origin/$BRANCH" -b "$BRANCH"
fi

[ -f "$DEST_DIR/flake.nix" ] || {
  echo "Error: flake.nix not found in $DEST_DIR"
  exit 1
}

echo "Configuration fetched to $DEST_DIR"
echo "To install, run: nixos-install --flake $DEST_DIR#hostname"
