{inputs, ...}: {
  imports = [
    ./boot.nix
    ./greetd.nix
    ./hardware.nix
    ./networking.nix
    ./nfs.nix
    ./packages.nix
    ./printing.nix
    ./security.nix
    ./services.nix
    ./steam.nix
    ./thunar.nix
    ./virtualisation.nix
    ./xserver.nix
    ./hardware.nix
    ./audio.nix
    ./system.nix
    ./xdg-portal.nix
    ./hyprland.nix
    ./applications.nix
    ./fonts.nix
    ./nh.nix
    inputs.stylix.nixosModules.stylix
  ];
}
