{ inputs, ... }:
{
  flake.modules.nixos.shell_opencode =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      opencodePkgs = inputs.opencode.inputs.nixpkgs.legacyPackages.${system};

      nodeModules = opencodePkgs.callPackage "${inputs.opencode}/nix/node_modules.nix" {
        rev = inputs.opencode.shortRev;
        # nix/hashes.json is stale for this tag: the 2.0.18 release commit
        # changed bun.lock after the last "chore: update nix node_modules
        # hashes" commit. Recompute with
        #   nix build .#node_modules_updater
        # after bumping the opencode input.
        hash = "sha256-9gJjhes2ueYckAgdeGlPwZcaIDdwB3ZnqK/XHHXhWNs=";
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

              # upstream still calls the removed `opencode completion` subcommand
              installShellCompletion --cmd opencode \
                --bash <($out/bin/opencode --completions bash) \
                --zsh <($out/bin/opencode --completions zsh) \
                --fish <($out/bin/opencode --completions fish)
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
