{ config, pkgs, system, inputs, color-schemes, ... }: {

  home.username = "k1ng";
  home.homeDirectory = "/home/k1ng";
  home.stateVersion = "24.11"; # Please read the comment before changing.
  targets.genericLinux.enable = true;
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "nvidia"
  ];

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

    ssh = {
      matchBlocks = {
        "*" = {
          extraOptions = {
            SetEnv = "TERM=xterm-256color";
          };
        };
      };
    };

    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installBatSyntax = true;
      clearDefaultKeybinds = false;
      package = (config.lib.nixGL.wrap inputs.ghostty.packages.${system}.default);

      # shellIntegration.enableZshIntegration = true;

      settings = {
        font-size = 14;
        font-family = "Comic Code Ligatures";
        font-family-bold = "ComicCodeLigatures-Bold";
        font-family-italic = "ComicCodeLigatures-Italic";
        font-family-bold-italic = "ComicCodeLigatures-BoldItalic";
        gtk-titlebar = false;
        window-decoration = false;
        bold-is-bright = true;
        copy-on-select = false;
        cursor-style = "block";
        window-save-state = "always";
        confirm-close-surface = false;
        gtk-tabs-location = "bottom";
        gtk-single-instance = true;
        background-opacity = 0.95;
        background-blur-radius = 20;
        window-padding-x = 2;
        window-padding-y = 2;
        window-vsync = false;
        shell-integration-features = "no-cursor,sudo,no-title";
        config-file = [
          (color-schemes + "/ghostty/catppuccin-mocha")
        ];

        keybind = [
          "ctrl+shift+c=copy_to_clipboard"
          "ctrl+shift+v=paste_from_clipboard"
          
          "ctrl+s>r=reload_config"
          "ctrl+s>x=close_surface"
          "ctrl+s>n=new_window"

          # Tabs
          "ctrl+s>c=new_tab"
          "ctrl+s>l=next_tab"
          "ctrl+s>h=previous_tab"
          "ctrl+s>shift+h=move_tab:-1"
          "ctrl+s>shift+l=move_tab:1"
          "ctrl+s>1=goto_tab:1"
          "ctrl+s>2=goto_tab:2"
          "ctrl+s>3=goto_tab:3"
          "ctrl+s>4=goto_tab:4"
          "ctrl+s>5=goto_tab:5"
          "ctrl+s>6=goto_tab:6"
          "ctrl+s>7=goto_tab:7"
          "ctrl+s>8=goto_tab:8"
          "ctrl+s>9=goto_tab:9"

          # Split
          "ctrl+s>\\=new_split:right"
          "ctrl+s>-=new_split:down"
          "ctrl+s>z=toggle_split_zoom"
        ];
      };
    };
  };

  home.packages = [
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
    pkgs.nixd
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
