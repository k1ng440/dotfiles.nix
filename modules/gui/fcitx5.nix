_: {
  flake.modules.nixos.gui =
    { pkgs, ... }:
    {

      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";

        fcitx5 = {
          waylandFrontend = true;
          ignoreUserConfig = true;

          addons = with pkgs; [
            fcitx5-mozc-ut
            fcitx5-gtk
            kdePackages.fcitx5-configtool
          ];

          settings.inputMethod = {
            GroupOrder."0" = "Default";
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "keyboard-us";
            };
            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "mozc";
          };
        };
      };

      # GTK_IM_MODULE is intentionally unset: native-wayland GTK apps use the
      # built-in text-input-v3 frontend, while XWayland GTK apps pick up the
      # fcitx im module from gtk settings.ini (see gui/gtk). Setting it globally
      # makes fcitx fire its "wayland diagnose" notification.
      # QT_IM_MODULE stays set because wlroots compositors lack text-input-v2.
      environment.sessionVariables = {
        QT_IM_MODULE = "fcitx";
        XMODIFIERS = "@im=fcitx";
        SDL_IM_MODULE = "fcitx";
        GLFW_IM_MODULE = "ibus";
      };

      # hyprland/niri have no session manager to process XDG autostart, so the
      # org.fcitx.Fcitx5.desktop entry never runs; launch the daemon directly.
      custom.startup = [
        {
          spawn = [
            "fcitx5"
            "-d"
          ];
        }
      ];
    };
}
