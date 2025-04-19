# Add your reusable home-manager modules to this directory, on their own file (https://wiki.nixos.org/wiki/NixOS_modules).
# These should be stuff you would like to share with others, not your personal configurations.
{ inputs, ... }: {
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
    ./rofi
    ./wlogout
    ./hyprland
    ./waybar/waybar-ddubs.nix # @@@ make this configurabable.
    ./swaync.nix
    ./fastfetch
    ./scripts
    ./mime.nix
  ];

  disabledModules = [
    "${inputs.stylix}/modules/neovim/hm.nix"
    "${inputs.stylix}/modules/lazygit/hm.nix"
    "${inputs.stylix}/modules/ghostty/hm.nix"
    "${inputs.stylix}/modules/nvim/hm.nix"
    "${inputs.stylix}/modules/waybar/hm.nix"
    "${inputs.stylix}/modules/rofi/hm.nix"
    "${inputs.stylix}/modules/hyprland/hm.nix"
    "${inputs.stylix}/modules/hyprlock/hm.nix"
    "${inputs.stylix}/modules/hyprlock/hm.nix"
  ];
}
