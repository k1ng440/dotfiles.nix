{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
{
  flake = {
    overlays = {
      # add flake.packages as pkgs.custom
      pkgsCustom = _: prev: {
        custom =
          (prev.custom or { })
          // (withSystem prev.stdenv.hostPlatform.system ({ config, ... }: config.packages));
      };

      # misc patches to packages in pkgs
      pkgsPatches = _: prev: {
        # nixos-small logo looks like ass
        fastfetch = prev.fastfetch.overrideAttrs (o: {
          patches = (o.patches or [ ]) ++ [ ./patches/fastfetch-nixos-old-small.patch ];
        });

        # add default font to silence null font errors
        lsix = prev.lsix.overrideAttrs (o: {
          postFixup = /* sh */ ''
            substituteInPlace $out/bin/lsix \
              --replace-fail '#fontfamily=Mincho' 'fontfamily="JetBrainsMono-NF-Regular"'
            ${o.postFixup}
          '';
        });

        # fix nix package count for nitch
        nitch = prev.nitch.overrideAttrs (o: {
          patches = (o.patches or [ ]) ++ [ ./patches/nitch-nix-pkgs-count.patch ];
        });

        # i686 packages (wine/bottles/lutris FHS envs) pull openldap but i686 is never cached
        # disable tests only for i686 — x86_64 stays unmodified and cache-compatible
        cyrus_sasl =
          if prev.stdenv.hostPlatform.is32bit then
            prev.cyrus_sasl.override { enableLdap = false; }
          else
            prev.cyrus_sasl;

        openldap =
          if prev.stdenv.hostPlatform.is32bit then
            prev.openldap.overrideAttrs (_: {
              doCheck = false;
            })
          else
            prev.openldap;

        # FIXME: remove on new release of statix
        statix = prev.statix.overrideAttrs (_o: rec {
          src = prev.fetchFromGitHub {
            owner = "oppiliappan";
            repo = "statix";
            rev = "43681f0da4bf1cc6ecd487ef0a5c6ad72e3397c7";
            hash = "sha256-LXvbkO/H+xscQsyHIo/QbNPw2EKqheuNjphdLfIZUv4=";
          };

          cargoDeps = prev.rustPlatform.importCargoLock {
            lockFile = src + "/Cargo.lock";
            allowBuiltinFetchGit = true;
          };
        });
      };

      # writeShellApplication with support for completions
      writeShellApplicationCompletions = _: prev: {
        custom = (prev.custom or { }) // {
          writeShellApplicationCompletions =
            {
              name,
              completions ? { },
              ...
            }@shellArgs:
            let
              inherit (prev) writeShellApplication writeText installShellFiles;
              # get the needed arguments for writeShellApplication
              app = writeShellApplication (lib.intersectAttrs (lib.functionArgs writeShellApplication) shellArgs);
              completionsStr = lib.concatMapAttrsStringSep " " (
                shell: content:
                lib.optionalString (builtins.elem shell [
                  "bash"
                  "zsh"
                  "fish"
                  "nushell"
                ]) "--${shell} ${writeText "${shell}-completion" content}"
              ) completions;
            in
            if completions == { } then
              app
            else
              app.overrideAttrs (o: {
                nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++ [ installShellFiles ];

                buildCommand = o.buildCommand + ''
                  installShellCompletion --cmd ${name} ${completionsStr}
                '';
              });
        };
      };
    };

    modules.nixos.core = _: {
      nixpkgs.overlays = [
        self.overlays.pkgsCustom
        self.overlays.pkgsPatches
        self.overlays.writeShellApplicationCompletions
        inputs.niri.overlays.niri
      ];
    };
  };
}
