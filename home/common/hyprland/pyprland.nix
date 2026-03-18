{ pkgs, ... }:
{
  home.packages = with pkgs; [ pyprland ];

  home.file.".config/pypr/config.toml".text = ''
    [pyprland]
    plugins = [
      "scratchpads",
      "expose",
      "fetch_client_menu",
      "lost_windows",
      "magnify",
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

    [scratchpads.music]
    animation = "fromTop"
    command = "spotify"
    class = "spotify"
    size = "75% 60%"
    max_size = "1920px 100%"
  '';
}
