{ config, pkgs, system, lib, inputs, ... }: {

  home.username = "k1ng";
  home.homeDirectory = "/home/k1ng";
  home.stateVersion = "24.11"; # Please read the comment before changing.
  targets.genericLinux.enable = true;

  nixGL = {
    packages = inputs.nixgl.packages;
    defaultWrapper = "nvidia"; # I'm using nvidia, change for your system
  };

  programs = {
    home-manager = {
      enable = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    ghostty = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    pkgs.bat
    pkgs.cowsay
    pkgs.devenv
    pkgs.mise
    pkgs.eza
    pkgs.nerd-fonts.fira-code
    pkgs.glow
    pkgs.ripgrep
    pkgs.thefuck
    pkgs.htop
    (config.lib.nixGL.wrap inputs.ghostty.packages.${system}.default)
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/k1ng/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    LOCALES_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };
}
