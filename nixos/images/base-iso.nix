{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mapAttrs' nameValuePair mkForce;
  inherit nixpkgs-unstable;
in
{
  environment.systemPackages = with pkgs; [
    zfs
    curl
    diskrsync
    httpie
    inputs.nixpkgs-unstable.neovim
    ntfs3g
    ntfsprogs
    partclone
    wget
  ];

  # Use helix as the default editor
  environment.variables.EDITOR = "nvim";

  networking = {
    firewall.enable = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
    usePredictableInterfaceNames = false;
  };

  services.resolved.enable = false;

  systemd = {
    network.enable = true;
    network.networks =
      mapAttrs'
        (
          num: _:
          nameValuePair "eth${num}" {
            extraConfig = ''
              [Match]
              Name = eth${num}
              [Network]
              DHCP = both
              LLMNR = true
              IPv4LL = true
              LLDP = true
              IPv6AcceptRA = true
              IPv6Token = ::521a:c5ff:fefe:65d9
              # used to have a stable address for zfs send
              Address = fd42:4492:6a6d:43:1::${num}/64
              [DHCP]
              UseHostname = false
              RouteMetric = 512
            '';
          }
        )
        {
          "0" = { };
          "1" = { };
          "2" = { };
          "3" = { };
        };
    services.update-prefetch.enable = false;
    services.sshd.wantedBy = mkForce [ "multi-user.target" ];
  };

  documentation = {
    enable = false;
    nixos.options.warningsAreErrors = false;
    info.enable = false;
  };

  nix = {
    gc.automatic = true;

    settings = {
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      flake-registry = ${inputs.flake-registry}/flake-registry.json
    '';

    nixPath = [
      "nixpkgs=${pkgs.path}"
    ];
  };

  # users.users.root.openssh.authorizedKeys.keys = [
  #   "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBKYBN4nrD/zxmIuuXvwqU3lqJPvjIHDs2fXOvq9ZKaglkNCK2p223siEMmOhN7qPZ+JKVPo0/oOrEQ8y/ovVbFgAAAAEc3NoOg== contact@iampavel.dev"
  # ];

  system.stateVersion = "24.11";
}
