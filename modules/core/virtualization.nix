{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (lib.elem "virtualization" config.machine.capabilities) {
    virtualisation = {
      libvirtd.enable = true;
      libvirtd.qemu = {
        swtpm.enable = true;
      };
      docker = {
        enable = true;
        daemon.settings = {
        };
      };
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
      virtio-win
      win-spice
    ];
    services.spice-vdagentd.enable = true;
  };
}
