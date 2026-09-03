_: {
  # perSystem =
  #   { pkgs, ... }:
  #   let
  #     source = (self.libCustom.nvFetcherSources pkgs).opencode;
  #     version = lib.removePrefix "v" source.version;
  #   in
  #   {
  #     packages.opencode = pkgs.opencode.overrideAttrs (o: {
  #       inherit version;
  #       inherit (source) src;
  #     });
  #   };

  flake.modules.nixos.shell_opencode =
    { pkgs, ... }:
    {
      # nixpkgs.overlays = [
      #   (_: _prev: {
      #     inherit (pkgs.custom) opencode;
      #   })
      # ];

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
