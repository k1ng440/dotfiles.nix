{
  flake.modules.nixos.wm =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf config.services.printing.enable {
        programs.system-config-printer.enable = true;
        services.system-config-printer.enable = true;

        environment.systemPackages = [
          pkgs.brscan4
          (pkgs.xsane.override { gimpSupport = true; })
        ];
      };
    };
}
