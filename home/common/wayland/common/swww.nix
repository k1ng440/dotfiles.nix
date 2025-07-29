{ pkgs, machine, ... }:
{
  home.packages = with pkgs; [
    swww
    coreutils
    findutils
  ];

  home.file."wallpaper-script" = {
    target = ".local/bin/change-wallpaper";
    text = ''
      #!${pkgs.bash}/bin/bash
      export PATH=${pkgs.coreutils}/bin:${pkgs.findutils}/bin:$PATH
      WALLPAPER=$(${pkgs.findutils}/bin/find /home/${machine.username}/Pictures/Wallpapers/wallpapers/ -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | ${pkgs.findutils}/bin/xargs -n 1 echo | ${pkgs.coreutils}/bin/shuf -n 1)
      ${pkgs.swww}/bin/swww img "$WALLPAPER"
    '';
    executable = true;
  };

  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww wallpaper daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "/bin/sh -c 'WAYLAND_DISPLAY=\"$(ls /run/user/%U/wayland-* | head -n1 | xargs basename)\" swww-daemon'";
      Restart = "always";
      RestartSec = 5;
      Environment = [
        "XDG_RUNTIME_DIR=/run/user/%U"
        "PATH=${pkgs.coreutils}/bin:${pkgs.swww}/bin:${pkgs.findutils}/bin"
      ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.wallpaper-cycler = {
    Unit = {
      Description = "Cycle wallpapers with swww";
      After = [ "swww-daemon.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash /home/${machine.username}/.local/bin/change-wallpaper";
      Environment = [
        "PATH=${pkgs.coreutils}/bin:${pkgs.findutils}/bin:${pkgs.swww}/bin"
      ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.timers.wallpaper-cycler = {
    Unit = {
      Description = "Timer for cycling wallpapers";
    };
    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "5min";
      Unit = "wallpaper-cycler.service";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
