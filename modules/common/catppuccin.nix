{
  config,
  lib,
  isHomeManager ? false,
  ...
}:
let
  cfg = config.machine.style.catppuccin;
in
{
  options = lib.optionalAttrs (!isHomeManager) {
    catppuccin.nvim.enable = lib.mkEnableOption "dummy catppuccin neovim option";
  };

  config = {
    catppuccin = {
      enable = cfg.enable;
      flavor = cfg.flavor;
      accent = cfg.accent;

      cache.enable = true;
      nvim.enable = false;
    };
  };
}
