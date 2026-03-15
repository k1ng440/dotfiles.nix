_: {
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        # --- Tags ---
        "tag +default-opacity, match:class .*"
        "tag +file-manager, match:class ^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"
        "tag +terminal, match:class ^(Alacritty|kitty|kitty-dropterm)$"

        # Browsers
        "tag +chromium-based-browser, match:class ((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)"
        "tag +firefox-based-browser, match:class ([fF]irefox|zen|librewolf)"
        "tag -default-opacity, match:tag chromium-based-browser"
        "tag -default-opacity, match:tag firefox-based-browser"

        "tag +projects, match:class ^(codium|codium-url-handler|VSCodium)$"
        "tag +projects, match:class ^(VSCode|code-url-handler)$"
        "tag +im, match:class ^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$"
        "tag +im, match:class ^([Ff]erdium)$"
        "tag +im, match:class ^([Ww]hatsapp-for-linux)$"
        "tag +im, match:class ^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
        "tag +im, match:class ^(teams-for-linux)$"
        "tag +settings, match:class ^(gnome-disks|wihotspot(-gui)?)$"
        "tag +settings, match:class ^([Rr]ofi)$"
        "tag +settings, match:class ^(file-roller|org.gnome.FileRoller)$"
        "tag +settings, match:class ^(nm-applet|nm-connection-editor|blueman-manager)$"
        "tag +settings, match:class ^(pavucontrol|org.pulseaudio.pavucontrol)$"
        "tag +settings, match:class ^(nwg-look|qt5ct|qt6ct|[Yy]ad)$"
        "tag +settings, match:class (xdg-desktop-portal-gtk)"
        "tag +settings, match:class (.blueman-manager-wrapped)"
        "tag +settings, match:class (nwg-displays)"

        # --- Game ---
        "content game, match:initial_class ^steam_app_[0-9]+$"
        "content game, match:class ^steam_app_[0-9]+$"
        "content game, match:class ^(gamescope)$"
        "content game, match:class ^(steam_proton)$"
        "tag +game, match:initial_class ^steam_app_[0-9]+$"
        "tag +game, match:class ^steam_app_[0-9]+$"
        "tag +game, match:class ^(gamescope)$"
        "tag +games, match:class ^(steam_proton)$"

        # --- Positioning ---
        "workspace 3 silent, match:initial_class ^(discord)$"
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
        "float on, match:class ^(mpv|com.github.rafostar.Clapper)$"
        "float on, match:class (codium|codium-url-handler|VSCodium), match:title negative:(.*codium.*|.*VSCodium.*)"
        "float on, match:class ^(com.heroicgameslauncher.hgl)$, match:title negative:(Heroic Games Launcher)"
        "float on, match:class ^([Ss]team)$, match:title negative:^([Ss]team)$"
        "float on, match:class ([Tt]hunar), match:title negative:(.*[Tt]hunar.*)"
        "float on, match:initial_title (Add Folder to Workspace)"
        "float on, match:initial_title (Open Files)"
        "float on, match:initial_title (wants to save)"
        "tag +floating-window, match:class (xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus), match:title ^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)"

        # --- Game ---
        "immediate on, no_blur on, fullscreen on, match:tag game"
        "suppress_event fullscreen, match:tag game"
        "suppress_event activate, match:tag game"
        "suppress_event focus, match:tag game"
        "rounding 0, no_anim on, opaque on, no_shadow on, match:tag game"
        "render_unfocused on, match:tag game"
        "float off, match:tag game"
        "idle_inhibit always, match:tag game"
        "xray on, match:tag game"

        # --- Picture-in-picture overlays ---
        "tag +pip, match:title (Picture.?in.?[Pp]icture)"
        "tag -default-opacity, match:tag pip"
        "float on, match:tag pip"
        "pin on, match:tag pip"
        "size 600 338, match:tag pip"
        "keep_aspect_ratio on, match:tag pip"
        "border_size 0, match:tag pip"
        "opacity 1 1, match:tag pip"
        "move (monitor_w-window_w-40) (monitor_h*0.04), match:tag pip"

        # --- qemu ---
        "tag -default-opacity, match:class qemu"
        "opacity 1 1, match:class qemu"

        # --- Sizing ---
        "size 70% 60%, match:initial_title (Open Files)"
        "size 70% 60%, match:initial_title (Add Folder to Workspace)"
        "size 70% 70%, match:tag settings*"
        "size 60% 70%, match:class ^([Ff]erdium)$"

        # --- Opacity ---
        "opacity 0.9 0.8, match:tag projects*"
        "opacity 0.94 0.86, match:tag im*"
        "opacity 0.9 0.8, match:tag file-manager*"
        "opacity 0.8 0.7, match:tag terminal*"
        "opacity 0.8 0.7, match:tag settings*"
        "opacity 0.8 0.7, match:class ^(gedit|org.gnome.TextEditor|mousepad)$"
        "opacity 0.9 0.8, match:class ^(seahorse)$"
        "opacity 0.95, match:class ^(kitty)$"

        # --- Misc ---
        "pin on, match:title ^(Picture-in-Picture)$"
        "keep_aspect_ratio on, match:title ^(Picture-in-Picture)$"
        "suppress_event maximize, match:class .*"

        # --- Specific Apps ---
        "float on, match:class com.saivert.pwvucontrol"
        "size 1401 492, match:class com.saivert.pwvucontrol"
        "move 6 40, match:class com.saivert.pwvucontrol"

        "opacity 1 1, match:class ^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$"
        "float on, pin on, dim_around on, center on, min_size 600 200, match:class com.gabm.satty"

        # Fix some dragging issues with XWayland
        "no_focus on, match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0"

        # Float LocalSend and fzf file picker
        "float on, match:class (Share|localsend)"
        "center on, match:class (Share|localsend)"
        "size 1100 700, match:class localsend"

        # --- Browsers ---
        # Video apps: remove chromium browser tag so they don't get opacity applied
        "tag -chromium-based-browser, match:class (chrome-youtube.com__-Default|chrome-app.zoom.us__wc_home-Default)"
        "tag -default-opacity, match:class (chrome-youtube.com__-Default|chrome-app.zoom.us__wc_home-Default)"

        "float on, match:class ^(firefox)$, match:title ^(Extension.*)$"
        "center on, match:class ^(firefox)$, match:title ^(Extension.*)$"

        # Force chromium-based browsers into a tile to deal with --app bug
        "tile on, match:tag chromium-based-browser"

        # Only a subtle opacity change, but not for video sites
        "opacity 1.0 0.97, match:tag chromium-based-browser"
        "opacity 1.0 0.97, match:tag firefox-based-browser"

        # --- Float Steam ---
        "float on, match:class steam"
        "center on, match:class steam, match:title Steam"
        "tag -default-opacity, match:class steam.*"
        "opacity 1 1, match:class steam.*"
        "size 1100 700, match:class steam, match:title Steam"
        "size 460 800, match:class steam, match:title Friends List"
        "idle_inhibit fullscreen, match:class steam"

        # No transparency on media windows
        "tag -default-opacity, match:class ^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$"
        "opacity 1 1, match:class ^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$"

        # --- Default opacity ---
        "opacity 0.97 0.9, match:tag default-opacity"
      ];
    };
  };
}
