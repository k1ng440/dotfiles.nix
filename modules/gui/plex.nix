{
  flake.modules.nixos.programs_plex =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.plex-desktop ];
    };
}
