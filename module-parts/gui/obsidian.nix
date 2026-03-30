{
  flake.modules.nixos.programs_obsidian =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.obsidian.override { inherit (pkgs) electron; })
      ];

      custom.persist = {
        home.directories = [
          ".config/obsidian"
          ".obsidian"
        ];
      };
    };
}
