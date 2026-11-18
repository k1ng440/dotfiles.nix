{
  flake.modules.nixos.gui =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.remmina ];

      custom.persist.home.directories = [
        ".config/remmina"
        ".local/share/remmina"
      ];
    };
}
