{
  flake.modules.nixos.gui =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ qalculate-gtk ];
    };
}
