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
      inherit (cfg) enable;
      inherit (cfg) flavor;
      inherit (cfg) accent;

      cache.enable = true;
      nvim.enable = false;
    };
  };
}
