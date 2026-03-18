_: {
  xdg.configFile."uwsm/env".text = ''
    export EDITOR=nvim
    export VISUAL=nvim
    export NIXOS_OZONE_WL=1
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export QT_QPA_PLATFORM="wayland;xcb"
    export GDK_BACKEND="wayland,x11,*"
    export SDL_VIDEODRIVER=wayland
    export CLUTTER_BACKEND=wayland
    export GTK_USE_PORTAL=1
    export _JAVA_AWT_WM_NONREPARENTING=1
    export QT_IM_MODULE="fcitx"
    export XMODIFIERS="@im=fcitx"
  '';
}
