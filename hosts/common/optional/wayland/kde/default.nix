{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.machine.windowManager.kde.enable {
    services = {
      xserver = {
        enable = true;
        videoDrivers = lib.mkIf (lib.elem "nvidia-gpu" config.machine.capabilities) [
          "nvidia"
        ];
      };

      displayManager = {
        plasma-login-manager = {
          enable = true;
          settings.General.DisplayServer = "x11-user";
        };

        autoLogin = {
          enable = true;
          user = config.machine.username;
        };
      };

      desktopManager.plasma6.enable = true;

      # Disable greetd when KDE is enabled because we use SDDM
      greetd.enable = lib.mkForce false;
    };

    environment.systemPackages = with pkgs; [
      kdePackages.kate
      kdePackages.kcalc
      kdePackages.spectacle
      kdePackages.gwenview
    ];

    # Open firewall for KDE Connect
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };
}
