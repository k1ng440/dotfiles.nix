_: {
  flake.modules.nixos.gui =
    {
      config,
      pkgs,
      lib,
      ...
    }:
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

      # the fcitx5 package only ships an XDG autostart entry, and nothing ever pulls in
      # `xdg-desktop-autostart.target` here: sessions come from ly or a getty autologin
      # shell, not a display manager, so the generated `app-org.fcitx.Fcitx5@autostart`
      # unit is generated but never started. run it as a real unit instead.
      systemd.user.services.fcitx5 = {
        description = "Fcitx 5 Input Method";
        documentation = [ "man:fcitx5(1)" ];
        after = [
          "dbus.socket"
          "graphical-session-pre.target"
        ];
        wantedBy = [ "graphical-session-pre.target" ];
        serviceConfig = {
          ExecStart = lib.getExe' config.i18n.inputMethod.package "fcitx5";
          Restart = "always";
          RestartSec = 1;
          Slice = "app.slice";
          # pinned in the unit too: a bare getty autologin never hands these to the
          # systemd user manager, so `environment.sessionVariables` alone is not enough
          # for the daemon itself.
          Environment = [
            "XMODIFIERS=@im=fcitx"
            "GTK_IM_MODULE=fcitx"
            "QT_IM_MODULE=fcitx"
            "SDL_IM_MODULE=fcitx"
            "GLFW_IM_MODULE=fcitx"
          ];
        };
      };

      environment.sessionVariables = {
        # the wayland frontend needs nothing: fcitx5's `waylandim` addon speaks the
        # standard `zwp_input_method_v2` protocol, which hyprland implements. the vars
        # below are what XWayland clients (this session runs DISPLAY=:0) need.
        GTK_IM_MODULE = "fcitx";
        QT_IM_MODULE = "fcitx";
        XMODIFIERS = "@im=fcitx";
        SDL_IM_MODULE = "fcitx";
        GLFW_IM_MODULE = "fcitx";
      };
    };
}
