{
  pkgs,
  config,
  inputs,
  outputs,
  stateVersion,
  username,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
in {

  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-index-database.hmModules.nix-index
    inputs.vscode-server.nixosModules.home
    inputs.hyprland.homeManagerModules.default

    ../modules/home-manager

    ./development
    ./desktops
    ./nvim
    ./lazygit
    ./git.nix
    ./packages.nix
    ./ghostty.nix
    ./fzf.nix
    ./fish.nix
  ];

  home = {
    inherit username stateVersion;

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

    homeDirectory =
      if isDarwin then
        "/Users/${username}"
      else
        "/home/${username}";
  };

  catppuccin = {
    accent = "blue";
    flavor = "mocha";
    bat.enable = config.programs.bat.enable;
    bottom.enable = config.programs.bottom.enable;
    btop.enable = config.programs.btop.enable;
    cava.enable = config.programs.cava.enable;
    fish.enable = config.programs.fish.enable;
    fzf.enable = config.programs.fzf.enable;
    starship.enable = config.programs.starship.enable;
    yazi.enable = config.programs.yazi.enable;
  };

  fonts.fontconfig.enable = true;
  news.display = "silent";


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
      width = 4096;
      height = 2160;
      refreshRate = 60;
      y = -1440;
      workspace = "9";
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
