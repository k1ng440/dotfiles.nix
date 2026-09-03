_: {
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.python3
        pkgs.uv
        pkgs.python3Packages.markitdown
      ];
    };
}
