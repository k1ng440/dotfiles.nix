{
  inputs,
  lib,
  hostSpec,
  config,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-index-database.hmModules.nix-index
    inputs.vscode-server.nixosModules.home
    inputs.hyprland.homeManagerModules.default

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
    username = lib.mkDefault config.hostSpec.username;
    homeDirectory = lib.mkDefault config.hostSpec.home;
    stateVersion = lib.mkDefault "24.11";
    sessionPath = [
      "$HOME/.local/bin"
    ];
    sessionVariables = {
      FLAKE = "$HOME/src/nix/nix-config";
      SHELL = "bash";
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

  fonts.fontconfig.enable = true;
  news.display = "silent";

  # See modules/home-manager/monitors.nix
  monitors = [
    {
      name = "DP-2";
      width = 3440;
      height = 1440;
      refresh_rate = 100;
      x = -3440;
      y = 0;
      vrr = 1;
      workspaces = [
        {
          name = "5";
          persistent = true;
          default = true;
          layout = "master";
          layout_orientation = "left";
        }
        {
          name = "6";
          persistent = true;
          default = false;
          layout = "master";
          layout_orientation = "left";
        }
        {
          name = "7";
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
      refresh_rate = 120;
      vrr = 1;
      primary = true;
      workspaces = [
        {
          name = "1";
          persistent = true;
          default = true;
          layout = "master";
        }
        {
          name = "2";
          persistent = true;
          default = false;
          layout = "master";
          on_start = [
            "spotify"
          ];
        }
        {
          name = "3";
          persistent = true;
          default = false;
          layout = "master";
          on_start = [ "discord" ];
        }
        {
          name = "4";
          persistent = true;
          default = false;
          layout = "master";
        }
        {
          name = "special:magic";
          persistent = true;
          default = true;
        }
        {
          name = "special:mail";
          persistent = true;
          default = true;
          on_start = [
            "thunderbird"
          ];
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
      ];
    }
  ];

  xdg.configFile."mimeapps.list".force = true;
}
