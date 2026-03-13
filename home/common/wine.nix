{ pkgs, ... }:
let
  winePkg = pkgs.wineWow64Packages.staging;

  winetricksPackages = [
    "corefonts"
    "comctl32"
    "dotnet48"
    "vcrun2015"
  ];

  winePath = pkgs.lib.makeBinPath [
    winePkg
    pkgs.winetricks
    pkgs.gnused
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnugrep
    pkgs.which
    pkgs.xorgserver
    pkgs.cabextract
    pkgs.vulkan-loader # Added for vkd3d/driver support
  ];
in
{
  systemd.user.services.winetricks-init = {
    Unit = {
      Description = "Initialize Wine prefix for Fallout 76 Tools";
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
        "WINE=${winePkg}/bin/wine"
        "WINE_BIN=${winePkg}/bin/wine"
        "LD_LIBRARY_PATH=${
          pkgs.lib.makeLibraryPath [
            pkgs.vulkan-loader
            pkgs.wayland
            pkgs.libGL
          ]
        }"
      ];

      ExecStart = pkgs.writeShellScript "init-wine-prefix" ''
        export WINE_BIN="${winePkg}/bin/wine"

        install_verb() {
          local verb=$1
          local marker="$WINEPREFIX/.winetricks-$verb"

          if [ ! -f "$marker" ]; then
            echo "Installing $verb..."
            if xvfb-run -a -s "-screen 0 1024x768x24" winetricks --unattended "$verb"; then
              touch "$marker"
              echo "$verb installed successfully."
            else
              echo "ERROR: Failed to install $verb"
              # Don't exit immediately, try the next one
            fi
          fi
        }

        # 1. Clean up corrupt prefix if kernel32 is missing
        if [ -d "$WINEPREFIX" ] && [ ! -f "$WINEPREFIX/drive_c/windows/system32/kernel32.dll" ]; then
           echo "Prefix exists but is corrupt (kernel32.dll missing). Nuking..."
           rm -rf "$WINEPREFIX"
        fi

        # 2. Force fresh initialization
        if [ ! -d "$WINEPREFIX" ]; then
           echo "Initializing fresh win64 prefix..."
           ${winePkg}/bin/wineboot -i
           ${winePkg}/bin/wineserver -w
        fi

        # 3. Install the list
        ${pkgs.lib.concatMapStringsSep "\n" (verb: "install_verb ${verb}") winetricksPackages}

        # 4. Registry Fixes
        ${winePkg}/bin/wine reg add "HKEY_CURRENT_USER\Software\Wine\Direct3D" /v "renderer" /t REG_SZ /d "gdi" /f
        ${winePkg}/bin/wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "LogPixels" /t REG_DWORD /d 120 /f

        echo "Initialization process finished."
      '';
      RemainAfterExit = true;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
