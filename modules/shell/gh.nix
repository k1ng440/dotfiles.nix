{ inputs, lib, ... }:
{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      # setup auth token for gh
      # sops.secrets.github_token.owner = user;

      nixpkgs.overlays = [
        (_: prev: {
          # wrap gh to set GITHUB_TOKEN
          gh = inputs.wrappers.lib.wrapPackage {
            pkgs = prev;
            package = prev.gh;
            # GH_CONFIG_DIR intentionally unset so gh uses $XDG_CONFIG_HOME/gh
            # (writable). Setting it to a nix-store path breaks `gh auth login`
            # because gh writes hosts.yml next to config.yml.
            /*
              TODO: Fix token
              preHook = ''
                GITHUB_TOKEN=$(cat "${config.sops.secrets.github_token.path}")
                export GITHUB_TOKEN
              '';
            */
          };
        })
      ];

      # needed for github authentication for private repos
      # adapted from home-manager:
      # https://github.com/nix-community/home-manager/blob/142acd7a7d9eb7f0bb647f053b4ddfd01fdfbf1d/modules/programs/gh.nix#L191
      programs.git.config = {
        credential =
          [
            "https://github.com"
            "https://gist.github.com"
          ]
          |> map (
            host:
            lib.nameValuePair host {
              helper = [
                ""
                "${lib.getExe pkgs.gh} auth git-credential"
              ];
            }
          )
          |> lib.listToAttrs;
      };

      environment.systemPackages = [ pkgs.gh ]; # overlay-ed above
    };
}
