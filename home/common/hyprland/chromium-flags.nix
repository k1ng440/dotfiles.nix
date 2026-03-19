_: {
  xdg = {
    configFile = {
      "brave-flags.conf".text = ''
        --ozone-platform=wayland
        --ozone-platform-hint=wayland
        --enable-features=TouchpadOverscrollHistoryNavigation
        # Chromium crash workaround for Wayland color management on Hyprland - see https://github.com/hyprwm/Hyprland/issues/11957
        --disable-features=WaylandWpColorManagerV1
      '';

      "chromium-flags.conf".text = ''
        --ozone-platform=wayland
        --ozone-platform-hint=wayland
        --enable-features=TouchpadOverscrollHistoryNavigation
        --disable-features=WaylandWpColorManagerV1
        # --oauth2-client-id=77185425430.apps.googleusercontent.com
        # --oauth2-client-secret=OTJgUOQcT7lO7GsGZq2G4IlT
      '';

      "edge-flags.conf".text = ''
        --ozone-platform-hint=auto
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
      '';
    };
  };
}
