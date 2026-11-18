{ inputs, ... }:
{
  flake.modules.nixos.shell_opencode =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      opencodePkgs = inputs.opencode.inputs.nixpkgs.legacyPackages.${system};

      nodeModules = opencodePkgs.callPackage "${inputs.opencode}/nix/node_modules.nix" {
        rev = inputs.opencode.shortRev;
        # nix/hashes.json is per-commit and goes stale: it is only refreshed by
        # upstream's "chore: update nix node_modules hashes" commits, so a
        # release tag can ship a bun.lock newer than its recorded hash. The
        # value below is hashes.json's at v1.18.34; recompute with
        #   nix build .#node_modules_updater
        # after bumping the opencode input.
        hash = "sha256-RIzpvDBR6GOfU2vjrtgP3LJ/j+gLxkMnJ9VE5Y65Pfo=";
      };

      opencode =
        (opencodePkgs.callPackage "${inputs.opencode}/nix/opencode.nix" {
          node_modules = nodeModules;
        }).overrideAttrs
          (_: {
            postInstall = ''
              # nixpkgs manages the binary, never let it replace itself
              wrapProgram $out/bin/opencode \
                --set-default OPENCODE_DISABLE_AUTOUPDATE true
            '';
          });
    in
    {
      environment.systemPackages = [
        opencode
      ];

      custom.persist = {
        home.directories = [
          ".config/opencode"
          ".local/share/opencode"
          ".local/state/opencode"
        ];
      };
    };
}
