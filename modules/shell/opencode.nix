{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      packages.opencode = inputs.opencode.packages.${system}.opencode;
    };

  flake.modules.nixos.shell_opencode =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_: _prev: {
          inherit (pkgs.custom) opencode;
        })
      ];

      environment.systemPackages = [
        pkgs.opencode
      ];

      custom.persist = {
        home.directories = [
          ".config/opencode"
          ".local/share/opencode"
        ];
      };
    };
}
