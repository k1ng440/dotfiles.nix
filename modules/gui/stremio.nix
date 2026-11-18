{
  flake.modules.nixos.programs_stremio =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.stremio-linux-shell ];
    };
}
