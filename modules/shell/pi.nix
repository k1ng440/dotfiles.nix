{ inputs, ... }:
{
  flake.modules.nixos.shell_pi =
    { pkgs, ... }:
    {
      imports = [ inputs.pi.nixosModules.default ];

      programs.pi.coding-agent = {
        enable = true;
        package = inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.coding-agent;

        # Run pi inside a bubblewrap (jail.nix) sandbox.
        # Default capabilities: network (for model API calls) + read-write cwd.
        # Extra tools are added so the agent can actually do work in the jail.
        jail = {
          enable = true;
          permissions =
            combinators: with combinators; [
              network
              mount-cwd
              # nix experimental features inside the jail (NIX_CONFIG is read by nix itself)
              (set-env "NIX_CONFIG" "experimental-features = nix-command flakes pipe-operators")
              (add-pkg-deps [
                pkgs.git
                pkgs.ripgrep
                pkgs.fd
                pkgs.jq
                pkgs.bash
                pkgs.coreutils
                pkgs.findutils
                pkgs.nix
                pkgs.gnugrep
                pkgs.gnused # sed
                pkgs.gawk # awk
                pkgs.diffutils # diff, cmp
                pkgs.gnutar # tar
                pkgs.gzip
                pkgs.zip
                pkgs.unzip
                pkgs.which
                pkgs.procps
                pkgs.openssl
                pkgs.curl
                pkgs.git
              ])
              # allow git to read the user's global config / credentials
              (try-readonly (noescape "~/.gitconfig"))
            ];
        };
      };

      custom.persist = {
        home.directories = [
          ".pi"
        ];
      };
    };
}
