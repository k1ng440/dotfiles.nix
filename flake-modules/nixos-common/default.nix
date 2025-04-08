localFlake:
{ self, lib, config, pkgs, ... }: {
  flake.nixosModules.common = {
    imports = [
      ./acme.nix
      ./audio.nix
      ./boot.nix
      ./fs-trim.nix
      ./i18n.nix
      ./minimal-docs.nix
      ./networking.nix
      ./nix.nix
      ./nvidia-gpu.nix
      ./powerManagement.nix
      ./security.nix
      ./services.nix
      ./shell.nix
      ./ssh.nix
      ./systemPackages.nix
      ./time.nix
    ];
  };
}
