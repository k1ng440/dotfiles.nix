{ inputs, ... }:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-index-database.hmModules.nix-index
    inputs.vscode-server.nixosModules.home
    inputs.hyprland.homeManagerModules.default

    ../modules/common
    ../modules/home

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
    sessionVariables = {
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
      workspace = "5";
      vrr = 1;
    }
    {
      name = "DP-1";
      width = 3440;
      height = 1440;
      refreshRate = 120;
      vrr = 1;
      primary = true;
    }
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      refreshRate = 30;
      y = -1080;
      vrr = 0;
      workspace = "6";
    }
  ];

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
