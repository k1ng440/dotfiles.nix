{pkgs, ...}: {
  imports = [
    ../services/sddm
  ];

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    hyprlock = {
      enable = true;
    };
  };

  environment.systemPackages = [
    pkgs.kitty # required for the default Hyprland config
  ];
}
