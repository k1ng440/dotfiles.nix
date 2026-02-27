{ pkgs, ... }:
let
  winePkg = pkgs.wineWowPackages.waylandFull;
  winePath = pkgs.lib.makeBinPath [
    winePkg
    pkgs.winetricks
    pkgs.gnused
    pkgs.coreutils
  ];
in
{
  systemd.user.services.winetricks-init = {
    Unit = {
      Description = "Initialize Wine prefix";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      Environment = [
        "WINEPREFIX=%h/.wine"
        "WINEARCH=win64"
        "WINEDEBUG=-all"
        "PATH=${winePath}"
        "DISPLAY=:0"
      ];

      ExecStart = pkgs.writeShellScript "init-wine-prefix" ''
        for i in {1..30}; do
          if [ -e /tmp/.X11-unix/X0 ]; then break; fi
          sleep 0.5
        done

        if [ ! -f "$WINEPREFIX/.winetricks-initialized" ]; then
          # wine reg add "HKEY_CURRENT_USER\Software\Wine\Drivers" /v "Graphics" /t REG_SZ /d "x11" /f
          winetricks -q corefonts comctl32 dotnet48 vcrun2015

          # Disable GPU acceleration in the UI to fix the "Black Menu"
          wine reg add "HKEY_CURRENT_USER\Software\Wine\Direct3D" /v "renderer" /t REG_SZ /d "gdi" /f
          wine reg add "HKEY_CURRENT_USER\Software\Wine\Direct3D" /v "MaxVersionGL" /t REG_DWORD /d 0x30002 /f

          touch "$WINEPREFIX/.winetricks-initialized"
        fi

        if [ ! -f "$WINEPREFIX/.theme-applied" ]; then
          wine reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v "Window" /t REG_SZ /d "30 30 30" /f
          wine reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v "WindowText" /t REG_SZ /d "255 255 255" /f
          wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "LogPixels" /t REG_DWORD /d 120 /f
          touch "$WINEPREFIX/.theme-applied"
        fi
      '';
      RemainAfterExit = true;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
