{ inputs, ... }:
{
  flake.modules.nixos.programs_hermes =
    { pkgs, lib, ... }:
    let
      hermesPackages = inputs.hermes.packages.${pkgs.stdenv.hostPlatform.system};

      # Upstream appends a patchelf patch (written for 0.19.2) to whatever
      # `patchelf` nixpkgs provides. This nixpkgs ships 0.15.2, so the patch
      # fails to apply. Swap the patched patchelf back for nixpkgs' own.
      fixPatchelf =
        drv:
        drv.overrideAttrs (old: {
          nativeBuildInputs = map (pkg: if (pkg.pname or null) == "patchelf" then pkgs.patchelf else pkg) (
            old.nativeBuildInputs or [ ]
          );
        });

      # The pinned node 26.12.1 artifact segfaults after autoPatchelf rewrites
      # its interpreter (overlapping LOAD segments). Use nixpkgs' node instead;
      # the pinned npm is still wrapped onto it.
      pmPackages = lib.mapAttrs (_: fixPatchelf) (
        builtins.listToAttrs (
          map (name: {
            name = lib.removePrefix "pm-" name;
            value = hermesPackages.${name};
          }) (builtins.filter (lib.hasPrefix "pm-") (builtins.attrNames hermesPackages))
        )
        // {
          node = pkgs.nodejs_26;
        }
      );

      hermes = hermesPackages.default.override { inherit pmPackages; };
      # `hermes` is `default` with all optional integrations; desktop points
      # back at the same wrapped binary.
      inherit (hermes) hermesDesktop;

      # Upstream picks XWayland when the NVIDIA proprietary driver is present,
      # and fcitx5's Ctrl+Space IME toggle does not reach an XWayland window.
      # Force Wayland. The desktop entry hardcodes the original store path, so
      # rewrite its Exec to the wrapper too.
      hermesDesktopWayland =
        pkgs.runCommandLocal "hermes-desktop-wayland"
          {
            nativeBuildInputs = [ pkgs.makeWrapper ];
          }
          ''
            mkdir -p $out/bin $out/share/applications
            makeWrapper ${hermesDesktop}/bin/hermes-desktop $out/bin/hermes-desktop \
              --set ELECTRON_OZONE_PLATFORM_HINT wayland
            substitute ${hermesDesktop}/share/applications/com.nousresearch.hermes.desktop \
              $out/share/applications/com.nousresearch.hermes.desktop \
              --replace-fail ${hermesDesktop}/bin/hermes-desktop $out/bin/hermes-desktop
          '';
    in
    {
      # Upstream's Home Manager module is skipped on purpose: it needs
      # `home.homeDirectory` and `lib.hm.dag`, and hjem is its own module
      # system with neither. The two packages are all a user needs --
      # `hermesDesktop` already points the app at our wrapped `hermes` with
      # HERMES_DESKTOP_HERMES, so there is one runtime and no bootstrap
      # download on first launch. The app starts its own `hermes serve`.
      environment.systemPackages = [
        hermes
        hermesDesktopWayland
      ];

      custom.persist.home.directories = [
        ".hermes" # HERMES_HOME
        ".config/Hermes" # electron userData
      ];
    };
}
