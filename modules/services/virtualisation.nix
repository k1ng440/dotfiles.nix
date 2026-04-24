{
  flake.modules.nixos.services_virtualisation =
    { config, pkgs, ... }:
    let
      inherit (config.custom.constants) user;
    in
    {
      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            swtpm.enable = true;
            vhostUserPackages = [ pkgs.virtiofsd ];
          };
        };
        vmVariant = {
          virtualisation = {
            memorySize = 1024 * 16;
            cores = 8;
          };
        };
      };
      services.spice-vdagentd.enable = true;
      programs.virt-manager.enable = true;
      users.users.${user}.extraGroups = [ "libvirtd" ];
      custom.persist = {
        root = {
          cache.directories = [ "/var/lib/libvirt" ];
        };
      };
    };
}
