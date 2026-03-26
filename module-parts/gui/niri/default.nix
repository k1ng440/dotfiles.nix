{ lib, ... }:
{
  flake.modules.nixos.wm_niri =
    { config, pkgs, ... }:
    {
      environment = {
        shellAliases = {
          niri-log = ''journalctl --user -u niri --no-hostname -o cat | awk '{$1=""; print $0}' | sed 's/^ *//' | sed 's/\x1b[[0-9;]*m//g' '';
        };
      };

      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
        useNautilus = false;
      };

      xdg.portal = {
        config = {
          niri = {
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
          };
        };
      };

      custom.programs = {
        # print-config = {
        #   niri = /* sh */ ''cat "${niriWrapped.env."NIRI_CONFIG"}" | ${lib.getExe pkgs.kdlfmt} format - | moor --lang kdl'';
        # };
      };
    };
}
