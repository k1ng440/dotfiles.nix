{ lib, ... }:
{
  flake.modules.nixos.core =
    { config, ... }:
    {
      options.custom = {
        specialisation = {
          current = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "The current specialisation being used";
          };

          hyprland.enable = lib.mkEnableOption "hyprland specialisation";
          niri.enable = lib.mkEnableOption "niri specialisation";
          mango.enable = lib.mkEnableOption "mango specialisation";
        };
      };

      config = {
        environment.sessionVariables = {
          __SPECIALISATION = config.custom.specialisation.current;
        };
      };
    };
}
