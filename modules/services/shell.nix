{pkgs, ...}: {
  programs = {
    fish.enable = true;
  };

  environment.shells = with pkgs; [
    bash
    fish
  ];

  users.defaultUserShell = pkgs.fish;
}
