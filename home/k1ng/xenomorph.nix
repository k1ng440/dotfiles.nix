{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-index-database.homeModules.nix-index
    inputs.hyprland.homeManagerModules.default
    inputs.noctalia.homeModules.default
    inputs.spicetify-nix.homeManagerModules.default

    ../../modules/common
    ../common
    ./development
    ./desktops
    ./nvim
    ./lazygit
    ./browsers
    ./packages.nix
    ./fzf.nix
    ./fish.nix
  ];

  home = {
    username = lib.mkDefault config.machine.username;
    homeDirectory = lib.mkDefault config.machine.home;
    stateVersion = lib.mkDefault "24.11";
    sessionPath = [
      "$HOME/.local/bin"
    ];
    sessionVariables = {
      FLAKE = "$HOME/src/nix/nix-config";
      EDITOR = "nvim";
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      MANROFFOPT = "-c";
      MICRO_TRUECOLOR = "1";
      PAGER = "bat";
      SUDO_EDITOR = "nvim";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  news.display = "silent";

  # See modules/home-manager/monitors.nix
  monitors = [
    {
      name = "DP-3";
      width = 3440;
      height = 1440;
      refresh_rate = 120;
      vrr = 1;
      primary = true;
      workspaces = [
        {
          name = "1";
          persistent = true;
          default = true;
          layout = "master";
          layout_orientation = "left";
        }
        {
          name = "2";
          persistent = true;
          default = false;
          layout = "master";
          layout_orientation = "left";
          on_start = [
            "spotify"
          ];
        }
        {
          name = "3";
          persistent = true;
          default = false;
          layout = "master";
          layout_orientation = "left";
          on_start = [ "vesktop" ];
        }
        {
          name = "4";
          persistent = true;
          default = false;
          layout = "master";
          layout_orientation = "left";
        }
      ];
    }
    {
      name = "DP-1";
      width = 3440;
      height = 1440;
      refresh_rate = 60;
      x = -3440;
      y = 0;
      vrr = 1;
      workspaces = [
        {
          name = "5";
          persistent = true;
          default = true;
          layout = "master";
          layout_orientation = "right";
        }
        {
          name = "6";
          persistent = true;
          default = false;
          layout = "master";
          layout_orientation = "right";
        }
        {
          name = "7";
          persistent = true;
          default = false;
          layout = "master";
          layout_orientation = "right";
        }
      ];
    }
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      refresh_rate = 60;
      x = 0;
      y = -1100;
      vrr = 0;
      workspaces = [
        {
          name = "8";
          persistent = true;
          default = true;
          layout = "master";
          on_start = [ ];
        }
        {
          name = "9";
          persistent = true;
          default = false;
          layout = "master";
          on_start = [ ];
        }
      ];
    }
  ];

  xdg.configFile."mimeapps.list".force = true;

  services.wlsunset = {
    enable = true;
    latitude = 23.8;
    longitude = 90.41;
  };

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.sleek;
      colorScheme = "RosePine";
      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle
        hidePodcasts
      ];
    };
}
