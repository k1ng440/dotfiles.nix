{ lib, ... }:
{
  flake.modules.nixos.gui =
    { config, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        file-roller
        p7zip-rar
        nemo-fileroller
        nemo-with-extensions
        webp-pixbuf-loader
      ];

      # Add a custom "open in terminal" option to the context menu
      hj.xdg.data.files."nemo/actions/open-in-ghostty.nemo_action".text = ''
        [Nemo Action]
        Name=Open in Terminal
        Comment=Open a terminal in this location
        Exec=ghostty --working-directory=%F
        Icon-Name=utilities-terminal
        Selection=Any
        Extensions=dir;
      '';

      custom = {
        dconf.settings = {
          # fix open in terminal
          "org/gnome/desktop/default-applications/terminal" = {
            exec = "xdg-terminal-exec";
          };
          "org/cinnamon/desktop/default-applications/terminal" = {
            exec = "xdg-terminal-exec";
          };
          "org/nemo/list-view" = {
            default-visible-columns = [
              "name"
              "size"
              "mime_type"
              "date_modified"
            ];
            enable-folder-expansion = true;
          };
          "org/nemo/preferences" = {
            default-folder-viewer = "list-view";
            show-hidden-files = true;
            start-with-dual-pane = true;
            date-format-monospace = true;
            # Needs to be a uint64!
            thumbnail-limit = lib.gvariant.mkUint64 (100 * 1024 * 1024); # 100MB
          };
          "org/nemo/window-state" = {
            sidebar-bookmark-breakpoint = lib.gvariant.mkInt32 0;
            sidebar-width = lib.gvariant.mkInt32 180;
          };
          "org/nemo/preferences/menu-config" = {
            selection-menu-make-link = true;
            selection-menu-copy-to = true;
            selection-menu-move-to = true;
            # hide the default "open in terminal options" to use the custom one
            background-menu-open-in-terminal = false;
            selection-menu-open-in-terminal = false;
          };
        };

        gtk.bookmarks = [
          "${config.hj.directory}/Downloads"
          "${config.hj.directory}/Documents"
          "${config.hj.directory}/Pictures/Wallpapers"
          "${config.hj.directory}/Projects"
          "${config.hj.directory}/Videos"
          "/persist Persist"
        ];
      };

      custom.persist = {
        home = {
          directories = [
            # Folder preferences such as view mode and sort order
            ".local/share/gvfs-metadata"
          ];
          cache.directories = [
            ".cache/thumbnails"
          ];
        };
      };
    };
}
