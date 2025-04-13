{pkgs}:
pkgs.writeShellScriptBin "pwvucontrol-toggle" ''
  # check if pwvucontrol is already running
  if pidof pwvucontrol > /dev/null; then
    pkill pwvucontrol
    exit 0;
  fi

  pwvucontrol
''

