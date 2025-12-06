{ ... }:
{
  xdg.configFile."brave-flags.conf".text = ''
    --ozone-platform=wayland
    --ozone-platform-hint=wayland
    --enable-features=TouchpadOverscrollHistoryNavigation
    # Chromium crash workaround for Wayland color management on Hyprland - see https://github.com/hyprwm/Hyprland/issues/11957
    --disable-features=WaylandWpColorManagerV1
  '';

  xdg.configFile."chromium-flags.conf".text = ''
    --ozone-platform=wayland
    --ozone-platform-hint=wayland
    --enable-features=TouchpadOverscrollHistoryNavigation
    --disable-features=WaylandWpColorManagerV1
  '';
}
