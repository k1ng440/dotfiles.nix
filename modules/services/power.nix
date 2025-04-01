{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    powertop
  ];

  powerManagement.enable = true;
}
