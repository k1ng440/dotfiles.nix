{
  pkgs,
  modulesPath,
  ...
}:
let
  sshKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqMh6k4NRNF4MzW/RYXlQ2FzFHkDE3rL3UuWT91ZzYK6oybFW2dXugxxHXA0a5d6jU4sToBB0zYLqCyCfb0rEJ+ukN0LIC+IJ2MVb7b7WSJyju0PeJqri1tice2quZO8C27rbYEMa1QgpUapDhEuNfFnDkXzkr0NnxOs2vwOdnGRm3VF1FRaV/0xmmJDeh8GmHdj40StH/UtNU63YvsTY1DJHb6Tw3O0hY4cvxx3z3SZv18bDDfn6EA/47Ao6BO88bT/b3qhmoQc55ESWX5siUk4/BtgEgQNuqZm8rxhRmW4NqdsWbLIwHdJCVn51DwokykP1A9x1QEAQRw5yqRy0fQ== rsa-key-20151130"
  ];
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./configurations.nix
    ./hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    neovim
    disko
    parted
    git
    networkmanager
    cryptsetup
    gptfdisk
    rsync

    (pkgs.writeShellScriptBin "fetch-config" (builtins.readFile ./fetch-config.sh))
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "nixos-installer";
  networking.useDHCP = true;
  services.openssh.enable = true;

  environment.etc."motd".text = ''
    Run `fetch-config` to fetch the configuration from GitHub.
  '';
  users.motdFile = "/etc/motd";
  users.users.root = {
    openssh.authorizedKeys.keys = sshKeys;
  };
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = sshKeys;
  };

  hardware.enableAllFirmware = false;
}
