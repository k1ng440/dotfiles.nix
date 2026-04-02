{
  flake.modules.nixos.programs_zoom =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = [ pkgs.zoom-us ];

      hj.xdg.config.files."zoomus.conf" = {
        text = ''
          [General]
          xwayland=false
          enableWaylandShare=true
        '';
      };

      custom.programs.which-key.menus = {
        z = {
          desc = "Zoom";
          cmd = lib.getExe pkgs.zoom-us;
        };
      };
    };
}
