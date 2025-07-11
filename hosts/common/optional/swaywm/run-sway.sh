#! /usr/bin/env sh

# see: https://man.sr.ht/~kennylevinsen/greetd/#how-to-set-xdg_session_typewayland

set -eu

# this teardown makes it easier to switch between compositors
unset DISPLAY SWAYSOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
dbus-update-activation-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE

export XDG_CURRENT_DESKTOP=sway # xdg-desktop-portal
export XDG_SESSION_DESKTOP=sway # systemd
export XDG_SESSION_TYPE=wayland # xdg/systemd
dbus-update-activation-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
systemctl --user import-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
sway --unsupported-gpu "$@" || true
