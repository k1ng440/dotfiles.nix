{
  flake.modules.nixos.programs_davinci-resolve =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = [ pkgs.davinci-resolve ];

      custom = {
        programs.which-key.menus = {
          d = {
            desc = "DaVinci Resolve";
            cmd = lib.getExe pkgs.davinci-resolve;
          };
        };
        persist = {
          home.directories = [
            ".local/share/DaVinciResolve"
            ".config/resolve"
          ];
        };
      };
    };
}
