{ diskPath }:
{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (import ./core-server.nix { diskPath = diskPath; })

    # services
    ./services/pulseaudio.nix
    ./services/printing.nix
    ./services/security.nix
    ./services/shell.nix
    ./services/xdg.nix

    # configs
    ./configs/fonts.nix
    ./configs/i3.nix
    ./configs/programs.nix
    ./configs/user-groups.nix
  ];

  environment.systemPackages = with pkgs; [
    parted
    (python3.withPackages (
      ps: with pkgs; [
        # Add packages that need root here
      ]
    ))
  ];

  services = {
    dbus.packages = [ pkgs.gcr ];
  };
}
