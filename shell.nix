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
  checks,
  ...
}:
{
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes pipe-operators";
    BOOTSTRAP_USER = "k1ng";
    BOOTSTRAP_SSH_PORT = "22";
    BOOTSTRAP_SSH_KEY = "~/.ssh/id_yubikey";

    inherit (checks.pre-commit-check) shellHook;
    buildInputs = checks.pre-commit-check.enabledPackages;

    nativeBuildInputs = builtins.attrValues {
      inherit (pkgs)
        nix
        home-manager
        nh
        git
        just
        pre-commit
        deadnix
        sops
        yq-go
        bats
        age
        ssh-to-age
        ;
    };
  };
}
