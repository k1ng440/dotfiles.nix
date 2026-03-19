{
  pkgs,
  config,
  machine,
  repo,
  ...
}:
pkgs.writeShellScriptBin "borg-helper" ''
  export BORG_RSH="ssh -i ${
    config.sops.secrets."ssh/borgbackup".path
  } -o StrictHostKeyChecking=yes -o UserKnownHostsFile=/etc/ssh/known_hosts"
  export BORG_PASSCOMMAND="cat ${config.sops.secrets."borgbackup/encryption_key".path}"
  REPO="${repo}/${machine.hostname}/${machine.username}-home"
  JOB="borgbackup-job-home-primary"
  BORG="${pkgs.borgbackup}/bin/borg"

  usage() {
    cat <<EOF
  Usage: borg-helper <command> [options]

  Commands:
    list   [n]                     List last N archives (default: 20)
    info   [archive]               Show repo stats, or info for a specific archive
    diff   <archive1> <archive2>   Show file changes between two archives
    restore <archive> <path> [dir] Extract path from archive (default dir: /tmp/borg-restore)
    mount  [archive] [mountpoint]  Mount repo or archive via FUSE (default: /tmp/borg-mount)
    umount [mountpoint]            Unmount a FUSE mountpoint (default: /tmp/borg-mount)
    run                            Trigger the backup job immediately via systemd
    status                         Show service status, timer, and last 30 log lines

  Examples:
    borg-helper list
    borg-helper list 5
    borg-helper info
    borg-helper info home-2024-01-15T02:00:00
    borg-helper diff home-2024-01-14T02:00:00 home-2024-01-15T02:00:00
    borg-helper restore home-2024-01-15T02:00:00 home/pavel/.bashrc
    borg-helper restore home-2024-01-15T02:00:00 home/pavel/Documents /tmp/recovered
    borg-helper mount
    borg-helper mount home-2024-01-15T02:00:00
    borg-helper mount home-2024-01-15T02:00:00 /mnt/borg
    borg-helper umount
    borg-helper run
    borg-helper status
  EOF
  }

  cmd="''${1:-}"
  shift || true

  case "$cmd" in
    list)
      n="''${1:-20}"
      exec "$BORG" list --last "$n" \
        --format='{archive:<60} {time} [{id:.8}]{NL}' \
        "$REPO"
      ;;

    info)
      if [ -n "''${1:-}" ]; then
        exec "$BORG" info "$REPO::$1"
      else
        exec "$BORG" info "$REPO"
      fi
      ;;

    diff)
      archive1="''${1:?borg-helper diff requires two archive names}"
      archive2="''${2:?borg-helper diff requires two archive names}"
      exec "$BORG" diff "$REPO::$archive1" "$archive2"
      ;;

    restore)
      archive="''${1:?borg-helper restore requires an archive name}"
      path="''${2:?borg-helper restore requires a path}"
      target="''${3:-/tmp/borg-restore}"
      mkdir -p "$target"
      echo "Restoring '$path' from '$archive' into '$target'..."
      cd "$target"
      exec "$BORG" extract --progress "$REPO::$archive" "$path"
      ;;

    mount)
      mountpoint="''${2:-/tmp/borg-mount}"
      mkdir -p "$mountpoint"
      if [ -n "''${1:-}" ]; then
        echo "Mounting archive '$1' at $mountpoint"
        target="$REPO::$1"
      else
        echo "Mounting entire repo at $mountpoint (all archives visible as subdirs)"
        target="$REPO"
      fi
      echo "Run 'borg-helper umount' to unmount."
      exec "$BORG" mount "$target" "$mountpoint"
      ;;

    umount)
      mountpoint="''${1:-/tmp/borg-mount}"
      exec "$BORG" umount "$mountpoint"
      ;;

    run)
      echo "Starting $JOB..."
      exec systemctl start "$JOB.service"
      ;;

    status)
      echo "=== Service status ==="
      systemctl status "$JOB.service" --no-pager -l

      echo ""
      echo "=== Timer status ==="
      systemctl status "$JOB.timer" --no-pager

      echo ""
      echo "=== Last 30 log lines ==="
      journalctl -u "$JOB.service" -n 30 --no-pager
      ;;

    help|--help|-h|"")
      usage
      ;;

    *)
      echo "borg-helper: unknown command '$cmd'" >&2
      echo "" >&2
      usage >&2
      exit 1
      ;;
  esac
''
