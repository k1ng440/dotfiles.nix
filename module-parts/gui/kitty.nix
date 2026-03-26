{
  flake.modules.nixos.programs_kitty =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.kitty ];
    };
}
