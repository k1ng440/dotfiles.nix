{
  flake.modules.nixos.gui =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.kdePackages.okular ];

      custom.persist = {
        home.directories = [
          ".config/okular"
          ".local/share/okular"
        ];
      };
    };
}
