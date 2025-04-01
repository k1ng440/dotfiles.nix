{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;

    packages = with pkgs; [
      # fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      noto-fonts-extra

      # nerd fonts
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "Iosevka"
        ];
      })

      # icons
      material-design-icons
      font-awesome
    ];

    fontconfig.defaultFonts = {
      serif = ["Noto Serif"];
      sansSerif = ["Noto Sans"];
      monospace = ["Iosevka Nerd Font"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
