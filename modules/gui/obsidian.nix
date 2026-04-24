{
  flake.modules.nixos.programs_obsidian =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = [
        pkgs.obsidian
      ];

      custom = {
        programs.which-key.menus = {
          o = {
            desc = "Obsidian";
            cmd = lib.getExe pkgs.obsidian;
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
