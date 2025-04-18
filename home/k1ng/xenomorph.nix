{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-index-database.hmModules.nix-index
    inputs.vscode-server.nixosModules.home
    inputs.hyprland.homeManagerModules.default

    ../../modules/common
    ../../modules/home

    ./development
    ./desktops
    ./nvim
    ./lazygit
    ./browsers
    ./git.nix
    ./packages.nix
    ./ghostty.nix
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

  hostSpec = {
    isAutoStyled = true;
    stylixImage = ../../assets/wallpapers/cyberpunk-1.jpg;
    email = "contact@iampavel.dev";
    userFullName = "Asaduzzaman Pavel";
  };

  # See modules/home-manager/monitors.nix
  monitors = [
    {
      name = "DP-2";
      width = 3440;
      height = 1440;
      refreshRate = 100;
      x = -3440;
      y = 0;
      vrr = 1;
      workspaces = [
        {
          name = "5";
          persistent = true;
          default = true;
          layout = "master";
        }
        {
          name = "6";
          persistent = true;
          default = false;
          layout = "master";
        }
        {
          name = "7";
          persistent = true;
          default = false;
          layout = "master";
        }
      ];
    }
    {
      name = "DP-1";
      width = 3440;
      height = 1440;
      refreshRate = 120;
      vrr = 1;
      primary = true;
      workspaces = [
        {
          name = "1";
          persistent = true;
          default = true;
          layout = "master";
          onStart = [ ];
        }
        {
          name = "2";
          persistent = true;
          default = false;
          layout = "master";
          onStart = [
            "thunderbird"
            "spotify"
          ];
        }
        {
          name = "3";
          persistent = true;
          default = false;
          layout = "master";
          onStart = [ "discord" ];
        }
        {
          name = "4";
          persistent = true;
          default = false;
          layout = "master";
        }
      ];
    }
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 0;
      y = -1100;
      vrr = 0;
      workspaces = [
        {
          name = "8";
          persistent = true;
          default = true;
          layout = "master";
          onStart = [ ];
        }
      ];
    }
  ];

  xdg.configFile."mimeapps.list".force = true;

  # sops = {
  #   age = {
  #     keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  #     generateKey = false;
  #   };
  #   defaultSopsFile = ../secrets/secrets.yaml;
  #   secrets = {
  #     asciinema.path = "${config.home.homeDirectory}/.config/asciinema/config";
  #     "keys/atuin".path = "${config.home.homeDirectory}/.local/share/atuin/key";
  #   };
  # };
}
