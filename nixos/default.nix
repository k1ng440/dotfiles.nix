{
  config,
  hostname,
  isInstall,
  isWorkstation,
  inputs,
  lib,
  modulesPath,
  outputs,
  pkgs,
  platform,
  stateVersion,
  username,
  ...
}:
{
  imports = [
    # Use module this flake exports; from modules/nixos
    #outputs.nixosModules.my-module
    # Use modules from other flakes
    inputs.catppuccin.nixosModules.catppuccin
    inputs.disko.nixosModules.disko
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-snapd.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    (modulesPath + "/installer/scan/not-detected.nix")
    ./${hostname}
    ./_mixins/configs
    ./_mixins/features
    ./_mixins/scripts
    ./_mixins/services
    ./_mixins/users
  ] ++ lib.optional isWorkstation ./_mixins/desktop;

  boot = {
    consoleLogLevel = lib.mkDefault 0;
    kernelModules = [ "vhost_vsock" ];
    kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;


    # Only enable the systemd-boot on installs, not live media (.ISO images)
    loader = lib.mkIf isInstall {
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.consoleMode = "max";
      systemd-boot.enable = true;
      systemd-boot.memtest86.enable = true;
      timeout = 10;
    };
  };
  documentation.enable = true;
  documentation.nixos.enable = false;
  documentation.man.enable = true;
  documentation.info.enable = false;
  documentation.doc.enable = false;

  environment = {
    # Eject nano and perl from the system
    defaultPackages =
      with pkgs;
      lib.mkForce [
        coreutils-full
        # inputs.nixpkgs-unstable.packages.${platform}.neovim
      ];

    systemPackages =
      with pkgs;
      [
        git
        nix-output-monitor
        rsync
        sops
      ]
      ++ lib.optionals isInstall [
        # inputs.nixos-needsreboot.packages.${platform}.default
        nvd
        nvme-cli
        smartmontools
        sops
      ];

    variables = {
      EDITOR = "nvim";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      # Add overlays exported from other flakes:
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Disable global registry
        flake-registry = "";
        nix-path = config.nix.nixPath;
        warn-dirty = false;
      };
      # Disable channels
      channel.enable = false;
      # Make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  nixpkgs.hostPlatform = lib.mkDefault "${platform}";

  programs = {
    command-not-found.enable = false;
    fish = {
      enable = true;
    };

    nh = {
      clean = {
        enable = true;
        extraArgs = "--keep-since 15d --keep 10";
      };
      enable = true;
      flake = "/home/${username}/nix-config";
    };

    nix-index-database.comma.enable = isInstall;

    nix-ld = lib.mkIf isInstall {
      enable = true;
      libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged
        # programs here, NOT in environment.systemPackages
      ];
    };
  };

  services = {
    fwupd.enable = isInstall;
    hardware.bolt.enable = true;
    smartd.enable = isInstall;
  };

  # https://dl.thalheim.io/
  sops = lib.mkIf (isInstall) {
    validateSopsFiles = false;
    age = {
      keyFile = "/var/lib/private/sops/age/keys.txt";
      generateKey = false;
    };
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets = {
      ssh_key = {
        mode = "0600";
        path = "/root/.ssh/id_rsa";
      };
      ssh_pub = {
        mode = "0644";
        path = "/root/.ssh/id_rsa.pub";
      };
      # Use `make-host-keys` to enroll new host keys.
      initrd_ssh_host_ed25519_key = {
        mode = "0600";
        path = "/etc/ssh/initrd_ssh_host_ed25519_key";
        sopsFile = ../secrets/initrd.yaml;
      };
      initrd_ssh_host_ed25519_key_pub = {
        mode = "0644";
        path = "/etc/ssh/initrd_ssh_host_ed25519_key.pub";
        sopsFile = ../secrets/initrd.yaml;
      };
      ssh_host_ed25519_key = {
        mode = "0600";
        path = "/etc/ssh/ssh_host_ed25519_key";
        sopsFile = ../secrets/${hostname}.yaml;
      };
      ssh_host_ed25519_key_pub = {
        mode = "0644";
        path = "/etc/ssh/ssh_host_ed25519_key.pub";
        sopsFile = ../secrets/${hostname}.yaml;
      };
      ssh_host_rsa_key = {
        mode = "0600";
        path = "/etc/ssh/ssh_host_rsa_key";
        sopsFile = ../secrets/${hostname}.yaml;
      };
      ssh_host_rsa_key_pub = {
        mode = "0644";
        path = "/etc/ssh/ssh_host_rsa_key.pub";
        sopsFile = ../secrets/${hostname}.yaml;
      };

      xenomorph_enc = {
        sopsFile = ../secrets/xenomorph_disks.key;
        format = "binary";
      };
      roglaptop_enc = {
        sopsFile = ../secrets/roglaptop_disks.key;
        format = "binary";
      };
    };
  };

  system = {
    # activationScripts = {
    #   nixos-needsreboot = lib.mkIf isInstall {
    #     supportsDryActivation = true;
    #     text = "${
    #       lib.getExe inputs.nixos-needsreboot.packages.${pkgs.system}.default
    #     } \"$systemConfig\" || true";
    #   };
    # };
    nixos.label = lib.mkIf isInstall "-";
    inherit stateVersion;
  };
}
