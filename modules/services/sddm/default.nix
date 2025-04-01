{...}: {
  imports = [
    ./theme.nix
  ];

  services = {
    xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = false;
        gdm.enable = false;
      };
    };

    displayManager.sddm = {
      enable = true;
    };
  };
}
