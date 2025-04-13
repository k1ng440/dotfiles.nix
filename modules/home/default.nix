# Add your reusable home-manager modules to this directory, on their own file (https://wiki.nixos.org/wiki/NixOS_modules).
# These should be stuff you would like to share with others, not your personal configurations.
{
  imports = [
    ./monitors.nix
    ./bat.nix
    ./btop.nix
    ./cava.nix
    ./emoji.nix
    ./gh.nix
    ./git.nix
    ./ghostty.nix
    ./htop.nix
    ./kitty.nix
    ./starship.nix
    ./swappy.nix
    ./virtmanager.nix
    ./zoxide.nix
    ./stylix.nix
    ./theming
    ./rofi
    ./wlogout
    ./hyprland
    ./waybar/waybar-simple.nix # @@@ make this configurabable.
    ./swaync.nix
    ./fastfetch
    ./scripts
  ];
}
