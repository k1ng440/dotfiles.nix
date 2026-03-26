{
  pkgs ?
    # If pkgs is not defined, instantiate nixpkgs from locked commit
    let
      lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
      nixpkgs = fetchTarball {
        url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
        sha256 = lock.narHash;
      };
    in
    import nixpkgs { overlays = [ ]; },
  checks ? { },
  ...
}:
let
  shell = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes pipe-operators";
    BOOTSTRAP_USER = "k1ng";
    BOOTSTRAP_SSH_PORT = "22";
    BOOTSTRAP_SSH_KEY = "~/.ssh/id_yubikey";

    inherit (checks.pre-commit-check or { }) shellHook;
    buildInputs = (checks.pre-commit-check or { }).enabledPackages or [ ];

    nativeBuildInputs =
      (builtins.attrValues {
        inherit (pkgs)
          nix
          home-manager
          nh
          git
          just
          npins
          nvfetcher
          pre-commit
          deadnix
          sops
          yq-go
          bats
          age
          ssh-to-age
          jq
          nodejs_24
          fzf
          ;
      })
      ++ [
        (pkgs.writeShellScriptBin "noctalia-update" ''
          noctalia-shell ipc call state all | ${pkgs.jq}/bin/jq -S .settings > home/common/wayland/noctalia/settings.json
          echo "Updated home/common/wayland/noctalia/settings.json"
        '')
      ];
  };
in
shell // { default = shell; }
