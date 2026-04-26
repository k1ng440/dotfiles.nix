{
  inputs,
  lib,
  self,
  ...
}:
{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      options.custom = {
        programs.niri = {
          settings = lib.mkOption {
            type = lib.types.submodule {
              freeformType = (pkgs.formats.json { }).type;
              # strings don't merge by default
              options.extraConfig = lib.mkOption {
                type = lib.types.lines;
                default = "";
                description = "Additional configuration lines.";
              };
            };
            description = "Niri settings, see https://github.com/Lassulus/wrappers/blob/main/modules/niri/module.nix for available options";
          };
        };
      };
    };

  flake.modules.nixos.wm =
    { config, pkgs, ... }:
    let
      niriVersion = "26.04";
      source = (self.libCustom.nvFetcherSources pkgs).niri;
      niriConfigPath = niriWrapped.env."NIRI_CONFIG";
      niriWrapped = inputs.wrappers.wrapperModules.niri.apply {
        inherit pkgs;
        package = lib.mkForce (
          pkgs.niri.overrideAttrs (
            o:
            (
              source
              // {
                inherit (o) patches; # needed for annoying version check
                version = niriVersion;

                postPatch = ''
                  patchShebangs resources/niri-session
                  substituteInPlace resources/niri.service \
                    --replace-fail 'ExecStart=niri' "ExecStart=$out/bin/niri"
                '';

                # Creating an overlay for buildRustPackage overlay (NOTE: this is an IFD)
                # https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/3
                cargoDeps = pkgs.rustPlatform.importCargoLock {
                  lockFile = "${source.src}/Cargo.lock";
                  allowBuiltinFetchGit = true;
                };

                doCheck = false; # faster builds
              }
            )
          )
        );

        settings = (config.custom.programs.niri.settings) // {
          binds = (config.custom.programs.niri.settings.binds or { }) // {
          };
        };
      };
    in
    {
      environment = {
        shellAliases = {
          niri-log = ''journalctl --user -u niri --no-hostname -o cat | awk '{$1=""; print $0}' | sed 's/^ *//' | sed 's/\x1b[[0-9;]*m//g' '';
        };
      };

      programs.niri = {
        enable = true;
        package = niriWrapped.wrapper;
        useNautilus = false;
      };

      # Reload niri
      system.userActivationScripts = {
        niri-reload-config = {
          text = lib.getExe (
            pkgs.writeShellApplication {
              name = "niri-reload-config";
              runtimeInputs = [
                config.programs.niri.package
                pkgs.procps
              ];
              text = ''
                if pgrep -x "niri" > /dev/null; then
                  niri msg action load-config-file --path niriConfigPath
                fi
              '';
            }
          );
        };
      };

      hj.xdg.config.files."niri/config.kdl".source = ./config.kdl;

      xdg = {
        autostart.enable = lib.mkDefault true;
        menus.enable = lib.mkDefault true;
        mime.enable = lib.mkDefault true;
        icons.enable = lib.mkDefault true;
      };

      xdg.portal = {
        extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
        configPackages = [ niriWrapped.wrapper ];
      };

      custom.programs = {
        ghostty.extraSettings = {
          background-opacity = lib.mkForce 0.95;
        };

        print-config = {
          # Use cat as kdlfmt tries to write the file in the nix store
          niri = /* sh */ ''cat "${niriConfigPath}" | ${lib.getExe pkgs.kdlfmt} format - | moor --lang kdl'';
        };
      };
    };
}
