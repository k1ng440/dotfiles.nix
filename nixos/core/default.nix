{inputs, ...}: {
  imports = [
    ./boot.nix
    ./applications.nix
    ./fonts.nix
    ./greetd.nix
    ./hardware.nix
    ./networking.nix
    ./nfs.nix
    ./nh.nix
    ./packages.nix
    ./printing.nix
    ./security.nix
    ./services.nix
    ./steam.nix
    ./thunar.nix
    ./virtualisation.nix
    ./xserver.nix
    ./hardware.nix
    inputs.stylix.nixosModules.stylix
  ];
}
