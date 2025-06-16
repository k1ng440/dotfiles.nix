{ pkgs, ... }:
{
  # Only enable either docker or podman -- Not both
  virtualisation = {
    libvirtd.enable = true;
    libvirtd.qemu = {
      swtpm.enable = true;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
    };
    docker.enable = true;
    podman.enable = false;
    spiceUSBRedirection.enable = true;
  };
  programs = {
    virt-manager.enable = true;
  };
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer # View Virtual Machines
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
  ];
  services.spice-vdagentd.enable = true;
}
