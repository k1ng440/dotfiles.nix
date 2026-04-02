{
  flake.modules.nixos.programs_kdeconnect =
    { pkgs, ... }:
    {
      programs.kdeconnect.enable = true;

      environment.systemPackages = [ pkgs.kdePackages.kdeconnect-kde ];

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
