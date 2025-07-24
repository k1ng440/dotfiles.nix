# https://www.reddit.com/r/swaywm/comments/1aq5rbf/swayopen_always_open_links_in_the_current/
{ pkgs, ... }:
let
  content = builtins.readFile ./sway-open.py;
in
pkgs.writers.writePython3Bin "sway-open" { } content
