{ config, ... }:
{
  # Bridge Stylix colors to the old theme format for gradual migration
  colors = {
    base = "#${config.lib.stylix.colors.base00}";
    surface = "#${config.lib.stylix.colors.base01}";
    overlay = "#${config.lib.stylix.colors.base02}";
    muted = "#${config.lib.stylix.colors.base03}";
    subtle = "#${config.lib.stylix.colors.base04}";
    text = "#${config.lib.stylix.colors.base05}";
    love = "#${config.lib.stylix.colors.base08}";
    gold = "#${config.lib.stylix.colors.base0A}";
    rose = "#${config.lib.stylix.colors.base0E}"; # Base16 rose is often 0E (magenta/pink)
    pine = "#${config.lib.stylix.colors.base0D}"; # Base16 pine is often 0D (blue)
    foam = "#${config.lib.stylix.colors.base0C}"; # Base16 foam is often 0C (cyan)
    iris = "#${config.lib.stylix.colors.base07}"; # Base16 iris as 07 (silver/whiteish) or 06
    highlight-low = "#${config.lib.stylix.colors.base01}";
    highlight-med = "#${config.lib.stylix.colors.base02}";
    highlight-high = "#${config.lib.stylix.colors.base03}";
  };
}
