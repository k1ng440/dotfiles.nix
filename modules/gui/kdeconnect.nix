{
  flake.modules.nixos.programs_kdeconnect =
    { pkgs, lib, ... }:
    {
      programs.kdeconnect.enable = true;

      environment.systemPackages = [ pkgs.kdePackages.kdeconnect-kde ];

      custom.startup = [
        {
          spawn = [ (lib.getExe' pkgs.kdePackages.kdeconnect-kde "kdeconnectd") ];
        }
      ];

      # Firewall ports for KDE Connect
      networking.firewall = {
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
        allowedUDPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
      };
    };
}
