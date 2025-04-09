{ lib, config, pkgs, ... }: {
  fonts = lib.mkIf config.desktop-environment.enable {
    packages = with pkgs; [
      noto-fonts-emoji
      noto-fonts-cjk-sans
      font-awesome
      symbola
      material-icons
      fira-code
      fira-code-symbols
    ];
  };
}
