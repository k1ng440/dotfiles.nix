{pkgs, ...}: {
  programs.starship = {
    enable = false;
    package = pkgs.starship;
  };
}

