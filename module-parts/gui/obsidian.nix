{
  flake.modules.nixos.programs_obsidian =
    { pkgs, lib, ... }:
    let
      obsidian = pkgs.obsidian.override { inherit (pkgs) electron; };
    in
    {
      environment.systemPackages = [
        obsidian
      ];

      custom = {
        programs.which-key.menus = {
          o = {
            desc = "Obsidian";
            cmd = lib.getExe obsidian;
          };
        };
        persist = {
          home.directories = [
            ".config/obsidian"
            ".obsidian"
          ];
        };
      };
    };
}
