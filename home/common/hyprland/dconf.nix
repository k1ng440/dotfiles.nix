_: {
  dconf.enable = true;
  dconf.settings = {
    "org/gtk/gtk4/settings/file-chooser" = {
      "show-hidden" = true;
    };

    "org/gtk/settings/file-chooser" = {
      "date-format" = "regular";
      "location-mode" = "path-bar";
      "show-hidden" = true;
      "show-size-column" = true;
      "show-type-column" = true;
      "sort-column" = "name";
      "sort-directories-first" = false;
      "sort-order" = "ascending";
      "type-format" = "category";
      "view-type" = "list";
    };

    "org/xfce/thunar" = {
      "last-remote-desktop-command" = "kitty";
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
