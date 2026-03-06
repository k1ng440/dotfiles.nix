{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        # --- Tags ---
        "tag +file-manager, match:class ^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"
        "tag +terminal, match:class ^(Alacritty|kitty|kitty-dropterm|ghostty)$"
        "tag +browser, match:class ^(Brave-browser(-beta|-dev|-unstable)?)$"
        "tag +browser, match:class ^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$"
        "tag +browser, match:class ^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$"
        "tag +browser, match:class ^([Tt]horium-browser|[Cc]achy-browser)$"
        "tag +projects, match:class ^(codium|codium-url-handler|VSCodium)$"
        "tag +projects, match:class ^(VSCode|code-url-handler)$"
        "tag +im, match:class ^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$"
        "tag +im, match:class ^([Ff]erdium)$"
        "tag +im, match:class ^([Ww]hatsapp-for-linux)$"
        "tag +im, match:class ^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
        "tag +im, match:class ^(teams-for-linux)$"
        "tag +games, match:class ^(gamescope)$"
        "tag +games, match:class ^steam_app_[0-9]+$"
        "tag +gamestore, match:class ^([Ss]team)$"
        "tag +gamestore, match:title ^([Ll]utris)$"
        "tag +gamestore, match:class ^(com.heroicgameslauncher.hgl)$"
        "tag +settings, match:class ^(gnome-disks|wihotspot(-gui)?)$"
        "tag +settings, match:class ^([Rr]ofi)$"
        "tag +settings, match:class ^(file-roller|org.gnome.FileRoller)$"
        "tag +settings, match:class ^(nm-applet|nm-connection-editor|blueman-manager)$"
        "tag +settings, match:class ^(pavucontrol|org.pulseaudio.pavucontrol)$"
        "tag +settings, match:class ^(nwg-look|qt5ct|qt6ct|[Yy]ad)$"
        "tag +settings, match:class (xdg-desktop-portal-gtk)"
        "tag +settings, match:class (.blueman-manager-wrapped)"
        "tag +settings, match:class (nwg-displays)"

        # --- Positioning ---
        "workspace 3 silent, match:initial_class discord"
        "move 72% 7%, match:title ^(Picture-in-Picture)$"
        "center on, match:class ^([Ff]erdium)$"
        "float on, match:class ^([Ww]aypaper)$"
        "center on, match:class ^(pavucontrol|org.pulseaudio.pavucontrol)$"
        "center on, match:class ([Tt]hunar), match:title negative:(.*[Tt]hunar.*)"
        "center on, float on, stay_focused on, match:class ^(gcr-prompter)$"

        # --- Idle Inhibition ---
        "idle_inhibit fullscreen, match:fullscreen 1"

        # --- Float Rules ---
        "float on, match:tag settings*"
        "float on, match:class ^([Ff]erdium)$"
        "float on, match:title ^(Picture-in-Picture)$"
        "float on, match:class ^(mpv|com.github.rafostar.Clapper)$"
        "float on, match:class (codium|codium-url-handler|VSCodium), match:title negative:(.*codium.*|.*VSCodium.*)"
        "float on, match:class ^(com.heroicgameslauncher.hgl)$, match:title negative:(Heroic Games Launcher)"
        "float on, match:class ^([Ss]team)$, match:title negative:^([Ss]team)$"
        "float on, match:class ([Tt]hunar), match:title negative:(.*[Tt]hunar.*)"
        "float on, match:initial_title (Add Folder to Workspace)"
        "float on, match:initial_title (Open Files)"
        "float on, match:initial_title (wants to save)"

        # --- Sizing ---
        "size 70% 60%, match:initial_title (Open Files)"
        "size 70% 60%, match:initial_title (Add Folder to Workspace)"
        "size 70% 70%, match:tag settings*"
        "size 60% 70%, match:class ^([Ff]erdium)$"

        # --- Opacity ---
        "opacity 1.0 1.0, match:tag browser*"
        "opacity 0.9 0.8, match:tag projects*"
        "opacity 0.94 0.86, match:tag im*"
        "opacity 0.9 0.8, match:tag file-manager*"
        "opacity 0.8 0.7, match:tag terminal*"
        "opacity 0.8 0.7, match:tag settings*"
        "opacity 0.8 0.7, match:class ^(gedit|org.gnome.TextEditor|mousepad)$"
        "opacity 0.9 0.8, match:class ^(seahorse)$ # gnome-keyring gui"
        "opacity 0.95 0.75, match:title ^(Picture-in-Picture)$"

        # --- Misc ---
        "pin on, match:title ^(Picture-in-Picture)$"
        "keep_aspect_ratio on, match:title ^(Picture-in-Picture)$"
        "no_blur on, match:tag games"
        "fullscreen on, match:tag games"

        # --- Specific Apps ---
        "float on, match:class com.saivert.pwvucontrol"
        "size 1401 492, match:class com.saivert.pwvucontrol"
        "move 6 40, match:class com.saivert.pwvucontrol"

        "float on, match:class ^(firefox)$, match:title ^(Extension.*)$"
        "center on, match:class ^(firefox)$, match:title ^(Extension.*)$"
        "opacity 0.80, match:class ^(kitty|com.mitchellh.ghostty)$"
        "opacity 1 1, match:class ^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$"
        "float on, pin on, dim_around on, center on, min_size 600 200, match:class com.gabm.satty"

        # --- Game ---
        "immediate yes, no_blur on, suppress_event fullscreen maximize activate focus, fullscreen on, tile off, match:tag games"
        "rounding 0, no_anim off, opaque on, no_shadow on, match:tag games"
      ];
    };
  };
}
