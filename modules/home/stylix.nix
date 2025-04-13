{ inputs, ...}: {
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

  stylix.targets = {
    # kde.useWallpaper = false;
    # waybar.enable = false;
    # rofi.enable = false;
    # hyprland.enable = false;
    # hyprlock.enable = false;
    # qt.enable = true;
    # gnome.enable = false;
  };
}
