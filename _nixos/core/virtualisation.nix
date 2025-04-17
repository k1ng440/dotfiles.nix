{ pkgs, ... }:
{
  # Only enable either docker or podman -- Not both
  virtualisation = {
    libvirtd.enable = false;
    docker.enable = true;
    podman.enable = false;
  };
  programs = {
    virt-manager.enable = false;
  };
  environment.systemPackages = with pkgs; [
    # virt-viewer # View Virtual Machines
  ];
}
