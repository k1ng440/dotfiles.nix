{diskPath}: {
  variables,
  lib,
  ...
}: {
  imports = [
    # Core
    ./core/nix.nix
    ./core/network.nix
    (import ./core/bootloader.nix {diskPath = diskPath;})
    ./core/libs.nix

    # Services
    ./services/docker.nix
    ./services/power.nix

    # Configs
    ./configs/system-packages.nix
  ];

  time.timeZone = variables.timeZone;
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      X11Forwarding = lib.mkDefault true;
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = lib.mkDefault false;
    };
    openFirewall = lib.mkDefault true;
  };
}
