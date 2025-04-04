#!/usr/bin/env bash

set +e  # Disable errexit
set +u  # Disable nounset
set +o pipefail  # Disable pipefail

TARGET_HOST="${1:-}"
TARGET_USER="${2:-k1ng}"
TARGET_BRANCH="${3:-main}"

function run_disko() {
    local DISKO_CONFIG="$1"
    local REPLY="n"

    # If the requested config doesn't exist, skip it.
    if [ ! -e "$DISKO_CONFIG" ]; then
        return
    fi

    echo "ALERT! Found $DISKO_CONFIG"
    echo "       Do you want to format the disks in $DISKO_CONFIG"
    echo "       This is a destructive operation!"
    echo
    read -p "Proceed with $DISKO_CONFIG format? [y/N]" -n 1 -r
    echo

    sudo true
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Workaround for mounting encrypted bcachefs filesystems.
        # - https://nixos.wiki/wiki/Bcachefs#NixOS_installation_on_bcachefs
        # - https://github.com/NixOS/nixpkgs/issues/32279
        sudo keyctl link @u @s
        sudo disko --mode disko "$DISKO_CONFIG"
    else
        sudo disko --mode mount "$DISKO_CONFIG"
    fi
}

echo "Unmounting /mnt"
sudo umount -R /mnt 2>/dev/null || true
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR! $(basename "$0") should be run as a regular user"
    exit 1
fi

if [ ! -d "$HOME/nix-config/.git" ]; then
    mkdir -p "$HOME/nix-config"
    pushd "$HOME/nix-config" || (echo "ERROR: $HOME/nix-config does not exist" && exit)
    git init
    git remote add origin https://github.com/k1ng440/dotfiles.nix.git
    git branch --set-upstream-to="origin/${TARGET_BRANCH}" "${TARGET_BRANCH}"
    git pull
    popd
fi

pushd "$HOME/nix-config" || (echo "ERROR: $HOME/nix-config does not exist" && exit)

if [[ -n "$TARGET_BRANCH" ]]; then
    git checkout "$TARGET_BRANCH"
fi

if [[ -z "$TARGET_HOST" ]]; then
    echo "ERROR! $(basename "$0") requires a hostname as the first argument"
    echo "       The following hosts are available"
    find nixos -mindepth 2 -maxdepth 2 -type f -name default.nix | cut -d'/' -f2 | grep -v iso
    echo ""
    exit 1
fi

if [[ -z "$TARGET_USER" ]]; then
    echo "ERROR! $(basename "$0") requires a username as the second argument"
    echo "       The following users are available"
    find nixos/_mixins/users/ -mindepth 1 -maxdepth 1 -type d | cut -d'/' -f4 | grep -v -E "nixos|root"
    echo ""
    exit 1
fi

SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
if [ ! -e "$SOPS_AGE_KEY_FILE" ]; then
    echo "WARNING! $SOPS_AGE_KEY_FILE was not found."
    echo "         Do you want to continue without it?"
    echo
    read -p "Are you sure? [y/N]" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        IP=$(ip route get 1.1.1.1 | awk '{print $7}' | head -n 1)
        mkdir -p "$(dirname "$SOPS_AGE_KEY_FILE")" 2>/dev/null || true
        echo "From a trusted host run:"
        echo "scp ~/.config/sops/age/keys.txt root@$IP:$SOPS_AGE_KEY_FILE"
        exit
    fi
fi

chown nixos:users "$SOPS_AGE_KEY_FILE" || true

if [ -x "nixos/$TARGET_HOST/disks.sh" ]; then
    if ! sudo "nixos/$TARGET_HOST/disks.sh" "$TARGET_USER"; then
        echo "ERROR! Failed to prepare disks; stopping here!"
        exit 1
    fi
else
    if [ ! -e "nixos/$TARGET_HOST/disks.nix" ]; then
        echo "ERROR! $(basename "$0") could not find the required nixos/$TARGET_HOST/disks.nix"
        exit 1
    fi

    DISK_FILE_CONFIG_FILENAME="nixos/$TARGET_HOST/disks.nix"
    KEY_LOCATION=$(awk -F'"' '/keylocation/ {gsub("file://", "", $2); print $2}' "DISK_FILE_CONFIG_FILENAME")
    if [ ! -f "$KEY_LOCATION" ]; then
        if [ -f "$SOPS_AGE_KEY_FILE" ]; then
            DISK_KEY="${HOME}/nix-config/secrets/${TARGET_HOST}_disks.key"
            sops decrypt "${DISK_KEY}" | sudo tee /etc/drive.key > /dev/null
        else 
            # Check if the machine we're provisioning expects a keyfile to unlock a disk.
            # If it does, generate a new key, and write to a known location.
            if [ "$KEY_LOCATION" != "" ] && [ ! -f "$KEY_LOCATION" ]; then
                echo -n "$(head -c32 /dev/random | base64)" > "$KEY_LOCATION"
            fi
        fi 
    fi

    echo "MD5 of key:"
    echo md5sum "$DISK_FILE_CONFIG_FILENAME"


    run_disko "$DISK_FILE_CONFIG_FILENAME"
    for CONFIG in $(find "nixos/$TARGET_HOST" -name "disks-*.nix" | sort); do
        run_disko "$CONFIG"
    done
fi

if ! mountpoint -q /mnt; then
    echo "ERROR! /mnt is not mounted; make sure the disk preparation was successful."
    exit 1
fi

echo "WARNING! NixOS will be re-installed"
echo "         This is a destructive operation!"
echo
read -p "Are you sure? [y/N]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Copy the sops keys.txt to the target install
    sudo nixos-install --show-trace --no-root-password --flake ".#$TARGET_HOST"

    # Rsync nix-config to the target install and set the remote origin to SSH.
    rsync -a --delete "$HOME/nix-config/" "/mnt/home/$TARGET_USER/nix-config/"
    pushd "/mnt/home/$TARGET_USER/nix-config"
    git remote set-url origin git@github.com:k1ng440/dotfiles.nix.git
    popd


    # If there is a keyfile for a data disk, put copy it to the root partition and
    # ensure the permissions are set appropriately.
    if [[ -f "/etc/drive.key" ]]; then
        sudo cp /etc/drive.key /mnt/etc/drive.key
        sudo chmod 0400 /mnt/etc/drive.key
    fi

    # Copy the sops keys.txt to the target install
    if [ -e "$HOME/.config/sops/age/keys.txt" ]; then
        mkdir -p "/mnt/home/$TARGET_USER/.config/sops/age"
        cp "$HOME/.config/sops/age/keys.txt" "/mnt/home/$TARGET_USER/.config/sops/age/keys.txt"
        chmod 600 "/mnt/home/$TARGET_USER/.config/sops/age/keys.txt"
    fi

    # Enter to the new install and apply the home-manager configuration.
    sudo nixos-enter --root /mnt --command "chown -R $TARGET_USER:users /home/$TARGET_USER"
    sudo nixos-enter --root /mnt --command "cd /home/$TARGET_USER/nix-config; env USER=$TARGET_USER HOME=/home/$TARGET_USER home-manager switch --flake \".#$TARGET_USER@$TARGET_HOST\""
    sudo nixos-enter --root /mnt --command "chown -R $TARGET_USER:users /home/$TARGET_USER"

fi
