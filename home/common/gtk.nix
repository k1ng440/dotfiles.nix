{
  config,
  pkgs,
  ...
}:
{
  catppuccin = {
    flavor = "mocha";
    accent = "lavender";
  };

  # GTK theme configuration
  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = "catppuccin-${config.catppuccin.flavor}-${config.catppuccin.accent}-compact";
      package = pkgs.catppuccin-gtk.override {
        accents = [ config.catppuccin.accent ];
        variant = config.catppuccin.flavor;
        size = "compact";
      };
    };
    gtk4.theme = config.gtk.theme;
    iconTheme = {
      name = "Tela-circle-dark";
      package = pkgs.tela-circle-icon-theme;
    };
    font = {
      name = "Roboto";
      size = 11;
    };
  };
}
