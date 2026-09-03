_: {
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.ast-grep ];
    };
}
