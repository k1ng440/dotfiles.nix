{ pkgs, ... }:
{
  home.packages = with pkgs; [ pyprland ];

  home.file.".config/hypr/pyprland.toml".text = ''
    [pyprland]
    plugins = [
      "scratchpads",
      "expose",
      "fetch_client_menu",
      "lost_windows",
      "magnify",
      "scratchpads",
      "shift_monitors",
      "toggle_special",
      "workspaces_follow_focus",
    ]
    [scratchpads.term]
    animation = "fromTop"
    command = "kitty --class kitty-dropterm"
    class = "kitty-dropterm"
    size = "75% 60%"
    max_size = "1920px 100%"
  '';
}
