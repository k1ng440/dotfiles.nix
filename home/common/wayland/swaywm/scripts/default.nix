{ pkgs, ... }:
{
  home.packages = with pkgs; [
    python313Packages.i3ipc
    (write "i3-toolwait" (builtins.readFile ./i3-toolwait.py))
  ];
}
