{ lib, ... }:
{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      options.custom = {
        gtk = {
          cursor = {
            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.simp1e-cursors;
              description = "Package providing the cursor theme.";
            };

            name = lib.mkOption {
              type = lib.types.str;
              default = "Simp1e-Tokyo-Night";
              description = "The cursor name within the package.";
            };

            size = lib.mkOption {
              type = lib.types.int;
              default = 28;
              description = "The cursor size.";
            };
          };
        };
      };
    };

  flake.modules.nixos.gui =
    { config, pkgs, ... }:
    let
      gtkCursor = config.custom.gtk.cursor;
    in
    {
      environment = {
        sessionVariables = {
          XCURSOR_SIZE = gtkCursor.size;
          XCURSOR_THEME = gtkCursor.name;
        };

        systemPackages = [
          gtkCursor.package
        ];
      };

      # Steam (and other FHS/CEF apps) fall back to a "default" cursor theme
      # that most distros ship. NixOS doesn't, so declare one inheriting the
      # active theme.
      xdg.icons.fallbackCursorThemes = [ gtkCursor.name ];

      # Add cursor icon link to $XDG_DATA_HOME/icons as well for redundancy.
      hj.xdg.data.files = {
        "icons/${gtkCursor.name}".source = "${gtkCursor.package}/share/icons/${gtkCursor.name}";
      };

      # Chromium/CEF (Steam's library/store web views) reads its cursor theme
      # from the X resource database (Xcursor.theme/size) on the root window,
      # not from XCURSOR_THEME. niri/hyprland never populate it, so those
      # views fall back to a plain black X cursor. Merge the values once the
      # X server is reachable; X resources are a pure X11 property, so apps
      # inside Steam's bwrap sandbox see them too.
      systemd.user.services.xcursor-resources = {
        description = "Set Xcursor theme/size in the X resource database";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          for _ in $(seq 1 50); do
            if ${pkgs.xrdb}/bin/xrdb -query >/dev/null 2>&1; then
              break
            fi
            sleep 0.2
          done
          printf 'Xcursor.theme: %s\nXcursor.size: %s\n' \
            '${gtkCursor.name}' '${toString gtkCursor.size}' \
            | ${pkgs.xrdb}/bin/xrdb -merge
        '';
      };
    };
}
