{
  inputs,
  ...
}:
{
  flake.modules.nixos.gui =
    { pkgs, lib, ... }:
    let
      # 3.3.0's test suite fails on Linux: `ShareShortcut` is gated with
      # `cfg!(target_os = "windows")`, so `lab-share-shortcut` never toggles in
      # the simulated "windows-settings" scene. The failing test gates the whole
      # package build, so skip checks until upstream fixes it.
      hex = inputs.hex.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs {
        doCheck = false;
      };

      # Upstream's Home Manager module needs `home.*` and `lib.hm.dag`; hjem
      # has neither. This is the part of it that matters: the supervised
      # `hex service`, bound to the compositor session targets the same way
      # dms is, so it starts after WAYLAND_DISPLAY reaches the user manager.
      sessionTargets = [
        "niri-session.target"
        "hyprland-session.target"
      ];
    in
    {
      environment.systemPackages = with pkgs; [
        qalculate-gtk
        hex
        poppler-utils
        tesseract
        imagemagick
      ];

      systemd.user.services.hex = {
        description = "Hex local voice dictation";
        wantedBy = sessionTargets;
        partOf = sessionTargets;
        after = sessionTargets;
        serviceConfig = {
          Type = "notify";
          NotifyAccess = "main";
          ExecStart = "${lib.getExe hex} service";
          Restart = "on-failure";
          RestartSec = 5;
          TimeoutStartSec = 35;
          TimeoutStopSec = 30;
          UMask = "0077";
        };
      };

      # Settings and downloaded speech models.
      custom.persist.home.directories = [ ".local/share/hex" ];
    };
}
