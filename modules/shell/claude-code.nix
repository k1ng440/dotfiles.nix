{ self, ... }: {
  perSystem =
    { pkgs, ... }:
    let
      source = (self.libCustom.nvFetcherSources pkgs).claude-code;
    in
    {
      packages.claude-code = pkgs.claude-code.overrideAttrs source;
    };

  flake.modules.nixos.shell_claude-code =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_: _prev: {
          inherit (pkgs.custom) claude-code;
        })
      ];

      environment.systemPackages = [
        pkgs.claude-code
      ];

      custom.persist = {
        home.directories = [
          ".claude"
        ];
      };
    };
}
